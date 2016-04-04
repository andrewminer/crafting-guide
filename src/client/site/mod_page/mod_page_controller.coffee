#
# Crafting Guide - mod_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

AdsenseController   = require '../common/adsense/adsense_controller'
BaseController      = require '../base_controller'
Item                = require '../../models/game/item'
ItemGroupController = require '../common/item_group/item_group_controller'
Mod                 = require '../../models/game/mod'
TutorialController  = require './tutorial/tutorial_controller'

########################################################################################################################

module.exports = class ModPageController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        options.templateName = 'mod_page'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

    # Event Methods ################################################################################

    onVersionChanged: ->
        @model.activeVersion = @$versionSelector.val()
        return false

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        effectiveModVersion:
            get: ->
                modVersion = @model.activeModVersion
                modVersion ?= @model.getModVersion Mod.Version.Latest
                modVersion.fetch() if modVersion?
                return modVersion

    # PageController Overrides #####################################################################

    getBreadcrumbs: ->
        return [
            $('<a href="/browse">Browse</a>')
            $("<b>#{@model.name}</b>")
        ]

    getTitle: ->
        return @model.name

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_adsenseController = @addChild AdsenseController, '.view__adsense', model: 'skyscraper'

        @$author             = @$('.about .author')
        @$description        = @$('.about .description')
        @$documentationLink  = @$('.about .documentation')
        @$downloadLink       = @$('.about .download')
        @$homePageLink       = @$('.about .homePage')
        @$itemGroups         = @$(".itemGroups")
        @$logo               = @$('.about img')
        @$title              = @$('.about .title')
        @$tutorialsContainer = @$('section.tutorials .panel')
        @$tutorialsSection   = @$('section.tutorials')
        @$versionSelector    = @$('.version select')
        @$warning            = @$('.warning')
        super

    refresh: ->
        @_refreshAboutBlock()
        @_refreshItemGroups()
        @_refreshTutorials()
        @_refreshVersionSelector()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'change .version select': 'onVersionChanged'

    # Private Methods ##############################################################################

    _refreshAboutBlock: ->
        if @model?
            @$author.text @model.author
            @$description.text @model.description
            @$documentationLink.attr 'href', @model.documentationUrl
            @$downloadLink.attr 'href', @model.downloadUrl
            @$homePageLink.attr 'href', @model.homePageUrl
            @$logo.attr 'src', c.url.modIcon modSlug:@model.slug
            @$title.text @model.name
        else
            @$author.text ''
            @$description.text ''
            @$documentationLink.attr 'href', ''
            @$downloadLink.attr 'href', ''
            @$homePageLink.attr 'href', ''
            @$logo.attr 'src', ''
            @$title.text ''

    _refreshItemGroups: ->
        @_groupControllers ?= []
        groupIndex = 0
        modVersion = @effectiveModVersion

        if modVersion?
            modVersion.eachGroup (group)=>
                controller = @_groupControllers[groupIndex]
                items = modVersion.allItemsInGroup group
                if not controller?
                    controller = new ItemGroupController
                        imageLoader: @_imageLoader
                        model:       items
                        modPack:     @_modPack
                        router:      @_router
                        title:       if group is Item.Group.Other then 'Items' else group

                    @_groupControllers.push controller
                    @$itemGroups.append controller.$el
                    controller.render()
                else
                    controller.modVersion = modVersion
                    controller.model      = items
                    controller.refresh()
                groupIndex++

        while @_groupControllers.length > groupIndex + 1
            @_groupControllers.pop().remove()

    _refreshTutorials: ->
        @_tutorialControllers ?= []
        index                  = 0
        tutorials              = @model.tutorials

        if tutorials.length > 0
            for tutorial in tutorials
                controller = @_tutorialControllers[index]
                if not controller?
                    controller = new TutorialController model: tutorial, router: @_router
                    @_tutorialControllers.push controller
                    @$tutorialsContainer.append controller.$el
                    controller.render()
                else
                    controller.model = tutorial

                index += 1

            while @_tutorialControllers.length > index
                @_tutorialControllers.pop().remove()

            @show @$tutorialsSection
        else
            @hide @$tutorialsSection

    _refreshVersionSelector: ->
        modVersions = @model.modVersions
        selectedModVersion = @effectiveModVersion

        @$versionSelector.empty()

        $option = $("<option value=\"none\">no</option>")
        if not @model.enabled
            @$warning.css display:''
            selectedModVersion = null
            $option.attr 'selected', true
        else
            @$warning.css display:'none'
        @$versionSelector.append $option

        for modVersion in @model.modVersions
            $option = $("<option value=\"#{modVersion.version}\">#{modVersion.version}</option>")
            if modVersion is selectedModVersion
                $option.attr 'selected', 'true'
            @$versionSelector.append $option
        @$versionSelector.css display:''
