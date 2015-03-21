###
Crafting Guide - mod_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

AdsenseController   = require './adsense_controller'
Item                = require '../models/item'
ItemGroupController = require './item_group_controller'
Mod                 = require '../models/mod'
ModPack             = require '../models/mod_pack'
PageController      = require './page_controller'
TutorialController  = require './tutorial_controller'
{Duration}          = require '../constants'
{Text}              = require '../constants'
{Url}               = require '../constants'

########################################################################################################################

module.exports = class ModPageController extends PageController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.delayStep    ?= 10
        options.templateName = 'mod_page'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack

        @_delayStep           = options.delayStep
        @_effectiveModVersion = null
        @_groupControllers    = []

    # Event Methods ################################################################################

    onVersionChanged: ->
        version = @$versionSelector.val()
        modVersion = @model.getModVersion version
        @_effectiveModVersion = modVersion
        if modVersion? then modVersion.fetch()
        @refresh()

    # Property Methods #############################################################################

    getEffectiveModVersion: ->
        return @_effectiveModVersion if @_effectiveModVersion?
        return null unless @model?

        modVersion = @model.activeModVersion
        modVersion ?= @model.getModVersion Mod.Version.Latest
        modVersion.fetch() if modVersion?

        return modVersion

    Object.defineProperties @prototype,
        effectiveModVersion: {get:@prototype.getEffectiveModVersion}

    # PageController Overrides #####################################################################

    getTitle: ->
        return @model?.name

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'

        @$name                = @$('.name')
        @$byline              = @$('.byline p')
        @$description         = @$('.description p')
        @$documentationLink   = @$('.documentation')
        @$downloadLink        = @$('.download')
        @$homePageLink        = @$('.homePage')
        @$groupContainer      = @$('.itemGroups')
        @$titleImage          = @$('.titleImage img')
        @$titleImageContainer = @$('.titleImage')
        @$tutorialsSection    = @$('.tutorials')
        @$tutorialsContainer  = @$('.tutorials .panel')
        @$versionSelector     = @$('select.version')

        super

    refresh: ->
        if @model?.isLoaded and @effectiveModVersion?.isLoaded
            @$byline.html "by #{@model.author}"
            @$description.html @model.description
            @$name.html @model.name
            @$titleImage.attr 'src', Url.modIcon modSlug:@model.slug

            @show()
        else
            @hide()

        @_refreshLink @$homePageLink, @model?.homePageUrl
        @_refreshLink @$documentationLink, @model?.documentationUrl
        @_refreshLink @$downloadLink, @model?.downloadUrl

        @_refreshItemGroups()
        @_refreshTutorials()
        @_refreshVersions()
        super

    # Backbone.View Methods ########################################################################

    events:
        'change select.version': 'onVersionChanged'

    # Private Methods ##############################################################################

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
                        imageLoader: @imageLoader
                        model:       items
                        modPack:     @modPack
                        title:       if group is Item.Group.Other then 'Items' else group

                    @_groupControllers.push controller
                    @$groupContainer.append controller.$el
                    controller.render()
                else
                    controller.modVersion = modVersion
                    controller.model      = items
                    controller.refresh()
                groupIndex++

        while @_groupControllers.length > groupIndex + 1
            controller = @_groupControllers.pop()
            controller.hide -> controller.$el.remove()

    _refreshLink: ($link, url)->
        if url?
            $link.attr 'href', url
            $link.removeClass 'hidden'
        else
            $link.addClass 'hidden'

    _refreshTutorials: ->
        @_tutorialControllers ?= []
        index                  = 0
        tutorials              = @model.tutorials

        if tutorials.length > 0
            for tutorial in tutorials
                controller = @_tutorialControllers[index]
                if not controller?
                    controller = new TutorialController model:tutorial
                    @_tutorialControllers.push controller
                    @$tutorialsContainer.append controller.$el
                    controller.render()
                else
                    controller.model = model

                index += 1

            while @_tutorialControllers.length > index
                controller = @_tutorialControllers.pop()
                controller.hide -> controller.$el.remove()

            @show @$tutorialsSection
        else
            @hide @tutorialsSection

    _refreshVersions: ->
        @$versionSelector.empty()
        return unless @model?

        @$versionSelector.removeClass 'hiding'

        effectiveModVersion = @effectiveModVersion
        versionCount = 0
        @model.eachModVersion (modVersion)=>
            option = $("<option value=\"#{modVersion.version}\">#{modVersion.version}</option>")
            if modVersion is effectiveModVersion
                option.attr 'selected', 'selected'
            @$versionSelector.append option
            versionCount++

        if versionCount <= 1
            @$versionSelector.attr 'disabled', 'disabled'
        else
            @$versionSelector.removeAttr 'disabled'
