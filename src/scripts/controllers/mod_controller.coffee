###
Crafting Guide - mod_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Event}        = require '../constants'
Mod            = require '../models/mod'
{RequiredMods} = require '../constants'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class ModController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.plan? then throw new Error 'options.plan is required'
        options.templateName  = 'mod'
        super options

        @_plan    = options.plan
        @_storage = options.storage

    # Event Methods ################################################################################

    onVersionChanged: ->
        @model.activeVersion = @$version.val()
        @_plan.removeUncraftableItems()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$version     = @$('.version')
        @$nameLink    = @$('.name a')
        @$nameText    = @$('.name p')
        @$description = @$('.description p')

        super

    refresh: ->
        if @model.activeVersion is Mod.Version.None
            @$el.addClass 'disabled'
        else
            @$el.removeClass 'disabled'

        @$version.empty()

        if not (@model.slug in RequiredMods)
            option = $("<option value=\"none\">Disabled</option>")
            if @model.activeVersion is Mod.Version.None
                option.attr 'selected', 'selected'
            @$version.append option

        @model.eachModVersion (modVersion)=>
            option = $("<option value=\"#{modVersion.version}\">#{modVersion.version}</option>")
            if modVersion is @model.activeModVersion
                option.attr 'selected', 'selected'
            @$version.append option

        @$nameLink.attr 'href', Url.mod(modSlug:@model.slug)
        @$nameText.html @model.name

        @$description.html @model.description

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'change .version': 'onVersionChanged'
            'click a':         'routeLinkClick'
