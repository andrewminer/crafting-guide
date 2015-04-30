###
Crafting Guide - mod_selector_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

$              = require 'jquery'
BaseController = require './base_controller'
Mod            = require '../models/mod'
_              = require 'underscore'
{Event}        = require '../constants'
{RequiredMods} = require '../constants'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class ModSelectorController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName  = 'mod_selector'
        super options

        @_storage = options.storage

    # Event Methods ################################################################################

    onVersionChanged: ->
        @model.activeVersion = @$version.val()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$version     = @$('select')
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
            'change select': 'onVersionChanged'
            'click a':       'routeLinkClick'
