#
# Crafting Guide - tutorial_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

AdsenseController         = require '../common/adsense/adsense_controller'
PageController            = require '../page_controller'
MarkdownSectionController = require '../common/markdown_section/markdown_section_controller'
VideoController           = require '../common/video/video_controller'

########################################################################################################################

module.exports = class TutorialPageController extends PageController

    constructor: (options={})->
        if not options.client?       then throw new Error 'options.client is required'
        if not options.modSlug?      then throw new Error 'options.modSlug is required'
        if not options.tutorialSlug? then throw new Error 'options.tutorialSlug is required'
        if not options.modPack?      then throw new Error 'options.modPack is required'

        options.model        ?= null
        options.templateName = 'tutorial_page'
        super options

        @_client       = options.client
        @_modPack      = options.modPack
        @_modSlug      = options.modSlug
        @_tutorialSlug = options.tutorialSlug

        @_modPack.on c.event.change, => @_resolveTutorial()
        @_resolveTutorial()

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return unless @_model?

        mod = @_modPack.getMod @_model.modSlug
        return unless mod?

        return c.text.tutorialDescription name:@_model.name, mod:mod.name

    getTitle: ->
        return null unless @model?
        return @model.name

    getBreadcrumbs: ->
        return [] unless @model? and @_modSlug?

        mod = @_modPack.getMod(@_modSlug)

        return [
            $("<a href='/browse'>Browse</a>")
            $("<a href='#{c.url.mod modSlug:@_modSlug}'>#{mod.name}</a>")
            $("<b>#{@model.name}</b>")
        ]

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_adsenseController = @addChild AdsenseController, '.view__adsense', model:'skyscraper'

        @$sourceModLink      = @$('.sourceMod a')
        @$officialLink       = @$('.officialLink a')
        @$officialLinkPanel  = @$('.officialLink')
        @$title              = @$('.title')
        @$titleImage         = @$('.about img')
        @$tutorialSections   = @$('.tutorial-sections')
        @$videosSection      = @$('.videos')
        @$videosSectionPanel = @$('.video-container')
        @$videosSectionTitle = @$('.videos h2')
        super

    refresh: ->
        if @model? and @model.isLoaded
            @_refreshOfficialLink()
            @_refreshSourceModLink()
            @_refreshTutorialSections()
            @_refreshTutorialTitle()
            @_refreshVideos()

            @show()
        else
            @hide()

        super

    # Private Methods ##############################################################################

    _refreshSourceModLink: ->
        @$sourceModLink.html @_modPack.getMod(@_modSlug).name
        @$sourceModLink.attr 'href', c.url.mod modSlug:@_modSlug

    _refreshOfficialLink: ->
        if @model.officialUrl?
            @$officialLink.attr 'href', @model.officialUrl
            @show @$officialLinkPanel
        else
            @hide @$officialLinkPanel

    _refreshTutorialTitle: ->
        @$title.html @model.name
        @$titleImage.attr 'src', c.url.tutorialIcon modSlug:@_modSlug, tutorialSlug:@_tutorialSlug

    _refreshTutorialSections: ->
        @_sectionControllers ?= []
        index = 0

        for section in @model.sections
            controller = @_sectionControllers[index]
            if not controller?
                controller = new MarkdownSectionController
                    tagName: 'section'
                    client:  @_client
                    title:   section.title
                    model:   section.content
                    modPack: @_modPack
                @_sectionControllers.push controller
                @$tutorialSections.append controller.$el
                controller.render()
            else
                controller.title = section.title
                controller.model = section.model
                controller.refresh()

            controller.imageBase = c.url.tutorialImageDir modSlug:@_modSlug, tutorialSlug:@_tutorialSlug
            index += 1

        while @_sectionControllers.length > index
            @_sectionController.pop().remove()

    _refreshVideos: ->
        @_videoControllers ?= []
        index = 0

        videos = @model?.videos or []
        if videos? and videos.length > 0
            @$videosSectionTitle.html if videos.length is 1 then 'Video' else 'Videos'

            for video in videos
                controller = @_videoControllers[index]
                if not controller?
                    controller = new VideoController model:video
                    @_videoControllers.push controller
                    @$videosSectionPanel.append controller.$el
                    controller.render()
                else
                    controller.model = video

                index += 1

            @show @$videosSection
        else
            @hide @$videosSection

        while @_videoControllers.length > index
            @_videoControllers.pop().remove()

    _resolveTutorial: ->
        return if @model?

        mod = @_modPack.getMod @_modSlug
        if not mod?
            logger.error => "cannot find the mod for: #{@_modSlug}"
            router.navigate '/', trigger:true
            return

        if not mod.isLoaded
            mod.fetch()
            return

        @model = mod.getTutorial @_tutorialSlug
        if not @model?
            logger.error => "mod #{@_modSlug} doesn't have a tutorial for: #{@_tutorialSlug}"
            return

        @model.fetch()
