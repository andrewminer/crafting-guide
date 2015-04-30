###
Crafting Guide - tutorial_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

AdsenseController         = require './adsense_controller'
BaseController            = require './base_controller'
MarkdownSectionController = require './markdown_section_controller'
VideoController           = require './video_controller'
{Duration}                = require '../constants'
{Event}                   = require '../constants'
{Url}                     = require '../constants'

########################################################################################################################

module.exports = class TutorialPageController extends BaseController

    constructor: (options={})->
        if not options.modSlug?      then throw new Error 'options.modSlug is required'
        if not options.tutorialSlug? then throw new Error 'options.tutorialSlug is required'
        if not options.modPack?      then throw new Error 'options.modPack is required'

        options.model        ?= null
        options.templateName = 'tutorial_page'
        super options

        @modPack      = options.modPack
        @imageLoader  = options.imageLoader
        @modSlug      = options.modSlug
        @tutorialSlug = options.tutorialSlug

        @modPack.on Event.change, => @_resolveTutorial()
        @_resolveTutorial()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'

        @$byline             = @$('.byline')
        @$bylineLink         = @$('.byline a')
        @$name               = @$('.name')
        @$officialLink       = @$('a.officialPage')
        @$sectionsContainer  = @$('.sections')
        @$title              = @$('h1.name')
        @$titleImage         = @$('.titleImage img')
        @$videosSection      = @$('.videos')
        @$videosSectionTitle = @$('.videos h2')
        @$videosSectionPanel = @$('.videos .panel')
        super

    refresh: ->
        if @model? and @model.isLoaded
            @_refreshByline()
            @_refreshOfficialUrl()
            @_refreshSections()
            @_refreshTitle()
            @_refreshVideos()

            @show()
        else
            @hide()

        super

    # Private Methods ##############################################################################

    _refreshByline: ->
        @$bylineLink.html @modPack.getMod(@modSlug).name
        @$bylineLink.attr 'href', Url.mod modSlug:@modSlug

    _refreshOfficialUrl: ->
        if @model.officialUrl?
            @$officialLink.attr 'href', @model.officialUrl
            @show @$officialLink
        else
            @hide @$officialLink

    _refreshTitle: ->
        @$title.html @model.name
        @$titleImage.attr 'src', Url.tutorialIcon modSlug:@modSlug, tutorialSlug:@tutorialSlug

    _refreshSections: ->
        @_sectionControllers ?= []
        index = 0

        for section in @model.sections
            controller = @_sectionControllers[index]
            if not controller?
                controller = new MarkdownSectionController title:section.title, model:section.content, modPack:@modPack
                @_sectionControllers.push controller
                @$sectionsContainer.append controller.$el
                controller.render()
            else
                controller.title = section.title
                controller.model = section.model
                controller.refresh()

            controller.imageBase = Url.tutorialImageDir modSlug:@modSlug, tutorialSlug:@tutorialSlug
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

        mod = @modPack.getMod @modSlug
        if not mod?
            logger.error => "cannot find the mod for: #{@modSlug}"
            router.navigate '/', trigger:true
            return

        if not mod.isLoaded
            mod.fetch()
            return

        @model = mod.getTutorial @tutorialSlug
        if not @model?
            logger.error => "mod #{@modSlug} doesn't have a tutorial for: #{@tutorialSlug}"
            return

        @model.fetch()
