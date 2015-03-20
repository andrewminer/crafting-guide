###
Crafting Guide - tutorial_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

AdsenseController         = require './adsense_controller'
BaseController            = require './base_controller'
MarkdownSectionController = require './markdown_section_controller'
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

        @$byline            = @$('.byline')
        @$bylineLink        = @$('.byline a')
        @$name              = @$('.name')
        @$officialLink      = @$('a.officialPage')
        @$sectionsContainer = @$('.sections')
        @$title             = @$('h1.name')
        @$titleImage        = @$('.titleImage img')
        super

    refresh: ->
        if @model? and @model.isLoaded
            @$el.removeClass 'hidden'
        else
            @$el.addClass 'hidden'

        @_refreshByline()
        @_refreshOfficialUrl()
        @_refreshSections()
        @_refreshTitle()
        super

    # Private Methods ##############################################################################

    _refreshByline: ->
        if @model?
            @$byline.removeClass 'hidden'
            @$bylineLink.html @modPack.getMod(@modSlug).name
            @$bylineLink.attr 'href', Url.mod modSlug:@modSlug
        else
            @$byline.addClass 'hidden'

    _refreshOfficialUrl: ->
        if @model?.officialUrl?
            @$officialLink.attr 'href', @model.officialUrl
            @$officialLink.removeClass 'hidden'
        else
            @$officialLink.addClass 'hidden'

    _refreshTitle: ->
        if @model?
            @$title.html @model.name
            @$titleImage.attr 'src', Url.tutorialIcon modSlug:@modSlug, tutorialSlug:@tutorialSlug
        else
            @$title.empty()
            @$titleImage.removeAttr 'src'

    _refreshSections: ->
        @_sectionControllers ?= []
        index = 0

        if @model?
            for section in @model.sections
                controller = @_sectionControllers[index]
                if not controller?
                    controller = new MarkdownSectionController title:section.title, model:section.content
                    controller.render()
                    @$sectionsContainer.append controller.$el
                    @_sectionControllers.push controller
                else
                    controller.title = section.title
                    controller.model = section.model
                    controller.refresh()

                index += 1

        while @_sectionControllers.length > index
            controller = @_sectionController.pop()
            controller.$el.fadeOut duration:Duration.normal, complete:-> @remove()

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
