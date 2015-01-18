###
Crafting Guide - mod_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Event}        = require '../constants'
Mod            = require '../models/mod'
{RequiredMods} = require '../constants'

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

    onEnabledChanged: ->
        return unless @rendered
        enabled = @$(':checked').length > 0
        if enabled
            @model.activeVersion = Mod.Version.Latest
        else
            @model.activeVersion = Mod.Version.None
            @_plan.removeUncraftableItems()

    # BaseController Overrides #####################################################################

    onWillRender: ->
        @model.fetch()
        if @_storage? then @_storage.register "mod:#{@model.slug}", @model, 'activeVersion'
        @model.on Event.change + ':activeModVersion', (mod, modVersion)=>
            if modVersion? then modVersion.fetch()

    onDidRender: ->
        @$enabled     = @$('td:nth-child(1) input')
        @$name        = @$('td:nth-child(2) p')
        @$description = @$('td:nth-child(3) p')
        super

    refresh: ->
        if @model.slug in RequiredMods
            @$enabled.attr 'checked', 'checked'
            @$enabled.attr 'disabled', 'disabled'
        else
            @$enabled.removeAttr 'disabled'
            if @model.activeVersion is Mod.Version.None
                @$enabled.removeAttr 'checked'
            else
                @$enabled.attr 'checked', 'checked'

        @$name.html "#{@model.name}"
        @$description.html "#{@model.description}"

    # Backbone.View Overrides ######################################################################

    events:
        'change input[type="checkbox"]': 'onEnabledChanged'
