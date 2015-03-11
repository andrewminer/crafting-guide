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

        Object.defineProperties this,
            effectiveModVersion: {get:@_getEffectiveModVersion}

    # Event Methods ################################################################################

    onVersionChanged: ->
        version = @$versionSelector.val()
        modVersion = @model.getModVersion version
        @_effectiveModVersion = modVersion
        if modVersion? then modVersion.fetch()
        @refresh()

    # PageController Overrides #####################################################################

    getTitle: ->
        return @model?.name

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'

        @$name              = @$('.name')
        @$byline            = @$('.byline p')
        @$description       = @$('.description p')
        @$documentationLink = @$('.documentation')
        @$downloadLink      = @$('.download')
        @$homePageLink      = @$('.homePage')
        @$groupContainer    = @$('.itemGroups')
        @$titleImage        = @$('.titleImage img')
        @$versionSelector   = @$('select.version')

        super

    refresh: ->
        if @model?
            @$name.html @model.name
            @$byline.html "by #{@model.author}"
            @$titleImage.attr 'src', Url.modIcon modSlug:@model.slug
            @$description.html @model.description

            @$el.slideDown duration:Duration.normal
        else
            @$el.slideUp duration:Duration.normal

        @_refreshLink @$homePageLink, @model.homePageUrl
        @_refreshLink @$documentationLink, @model.documentationUrl
        @_refreshLink @$downloadLink, @model.downloadUrl

        @_refreshItemGroups()
        @_refreshVersions()
        super

    # Backbone.View Methods ########################################################################

    events:
        'change select.version': 'onVersionChanged'

    # Private Methods ##############################################################################

    _getEffectiveModVersion: ->
        return @_effectiveModVersion if @_effectiveModVersion?
        return null unless @model?

        modVersion = @model.activeModVersion
        modVersion ?= @model.getModVersion Mod.Version.Latest
        modVersion.fetch() if modVersion?

        return modVersion

    _refreshItemGroups: ->
        groupIndex = 0
        modVersion = @effectiveModVersion
        if modVersion?
            modVersion.eachGroup (group)=>
                controller = @_groupControllers[groupIndex]
                items = modVersion.allItemsInGroup group
                if not controller?
                    title = if group is Item.Group.Other then 'Items' else group
                    controller = new ItemGroupController
                        imageLoader: @imageLoader
                        model:       items
                        modPack:     @modPack
                        title:       title
                    controller.render()
                    @$groupContainer.append controller.$el
                    @_groupControllers[groupIndex] = controller
                else
                    controller.modVersion = modVersion
                    controller.model      = items
                    controller.refresh()
                groupIndex++

        while @_groupControllers.length > groupIndex + 1
            controller = @_groupControllers.pop()
            controller.$el.slideUp duration:Duration.normal, -> @remove()

    _refreshLink: ($link, url)->
        if url?
            $link.slideDown duration:Duration.normal
            $link.attr 'href', url
        else
            $link.slideUp duration:Duration.normal

    _refreshVersions: ->
        @$versionSelector.empty()
        return unless @model?

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
