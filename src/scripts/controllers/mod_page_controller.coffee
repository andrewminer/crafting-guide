###
Crafting Guide - mod_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController      = require './base_controller'
{Duration}          = require '../constants'
Mod                 = require '../models/mod'
ModPack             = require '../models/mod_pack'
ItemGroupController = require './item_group_controller'
{Url}               = require '../constants'

########################################################################################################################

module.exports = class ModPageController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.delayStep    ?= 10
        options.templateName = 'mod_page'
        super options

        @_delayStep           = options.delayStep
        @_effectiveModVersion = null
        @_groupControllers    = []
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
        @$name.html if @model? then @model.name else ''
        @$byline.html if @model? then "by #{@model.author}" else ''
        @$titleImage.attr 'src', (if @model? then Url.modLogoImage(modSlug:@model.slug) else '')
        @$description.html if @model? then @model.description else ''

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
        modVersion.fetch()

        return modVersion

    _refreshItemGroups: ->
        groupIndex = 0
        modVersion = @effectiveModVersion
        modVersion.eachGroup (group)=>
            controller = @_groupControllers[groupIndex]
            if not controller?
                controller = new ItemGroupController model:group, modVersion:modVersion, modPack:@_modPack
                controller.render()
                @$groupContainer.append controller.$el
                @_groupControllers[groupIndex] = controller
            else
                controller.modVersion = modVersion
                controller.model      = group
                controller.refresh()
            groupIndex++

        while @_groupControllers.length > groupIndex + 1
            controller = @_groupControllers.pop()
            controller.$el.slideUp duration:Duration.fast, -> @remove()

    _refreshLink: ($link, url)->
        if url?
            $link.fadeIn duration:Duration.fast
            $link.attr 'href', url
        else
            $link.fadeOut duration:Duration.fast

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
