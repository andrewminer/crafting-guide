###
Crafting Guide - mod_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Duration}     = require '../constants'
Mod            = require '../models/mod'
ModPack        = require '../models/mod_pack'
ItemController = require './item_controller'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class ModPageController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.delayStep    ?= 10
        options.templateName = 'mod_page'
        super options

        @_delayStep           = options.delayStep
        @_effectiveModVersion = null
        @_itemControllers     = []
        @_modPack             = options.modPack

        Object.defineProperties this,
            effectiveModVersion: {get:@_getEffectiveModVersion}

    # Event Methods ################################################################################

    onVersionChanged: ->
        version = @$versionSelector.val()
        modVersion = @model.getModVersion version
        @_effectiveModVersion = modVersion
        if modVersion? then modVersion.fetch()
        @refresh()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$name            = @$('.name')
        @$byline          = @$('.byline p')
        @$description     = @$('.description p')
        @$homePageLink    = @$('.homePage')
        @$items           = @$('.items .panel')
        @$titleImage      = @$('.titleImage img')
        @$versionSelector = @$('select.version')
        @$wikiLink        = @$('.wiki')

        super

    refresh: ->
        @$name.html if @model? then @model.name else ''
        @$byline.html if @model? then "by #{@model.author}" else ''
        @$titleImage.attr 'src', (if @model? then Url.modLogoImage(modSlug:@model.slug) else '')
        @$description.html if @model? then @model.description else ''

        @_refreshHomePageLink()
        @_refreshItems()
        @_refreshVersions()
        super

    # Backbone.View Methods ########################################################################

    events:
        'change select.version': 'onVersionChanged'

    # Private Methods ##############################################################################

    _createItemController: (item)->
        controller = new ItemController model:item, modPack:@_modPack
        controller.$el.hide()
        controller.render()

        @_itemControllers.push controller
        @$items.append controller.$el
        controller.$el.fadeIn duration:Duration.fast

    _getEffectiveModVersion: ->
        return @_effectiveModVersion if @_effectiveModVersion?
        return null unless @model?

        modVersion = @model.activeModVersion
        modVersion ?= @model.getModVersion Mod.Version.Latest
        return modVersion

    _refreshHomePageLink: ->
        if @model.homePageUrl?
            @$homePageLink.fadeIn duration:Duration.fast
            @$homePageLink.attr 'href', @model.homePageUrl
        else
            @$homePageLink.fadeOut duration:Duration.fast

    _refreshItems: ->
        controllerIndex = 0
        delay = 0

        effectiveModVersion = @effectiveModVersion
        if effectiveModVersion?
            @$items.show duration:Duration.fast
            effectiveModVersion.eachItem (item)=>
                controller = @_itemControllers[controllerIndex]
                if not controller?
                    _.delay (=> @_createItemController item), delay
                    delay += @_delayStep
                else
                    controller.model = item
                controllerIndex += 1
        else
            @$items.hide duration:Duration.fast

        while @_itemControllers.length > controllerIndex
            controller = @_itemControllers.pop()
            controller.$el.slideUp duration:Duration.fast, complete:-> @remove()

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
