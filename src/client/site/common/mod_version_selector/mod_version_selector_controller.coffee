#
# Crafting Guide - mod_version_selector.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require "../../base_controller"
{Mod}          = require("crafting-guide-common").models

########################################################################################################################

module.exports = class ModVersionSelectorController extends BaseController

    constructor: (options={})->
        if options.model?.constructor isnt Mod then throw new Error "options.model must be a Mod"
        options.templateName = "common/mod_version_selector"
        super options

    # Event Methods ################################################################################

    onToggleEnabled: ->
        if not @model.isEnabled
            tracker.trackEvent c.tracking.category.modPack, "toggle-on", @model.id
            @model.isEnabled = true
        else
            tracker.trackEvent c.tracking.category.modPack, "toggle-off", @model.id
            @model.isEnabled = false

        return false

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$toggleSection = @$(".toggle")
        @$warning       = @$(".warning")
        super

    refresh: ->
        console.log "refreshing"
        @_refreshEnabled()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            "click .toggle": "onToggleEnabled"

    # Private Methods ##############################################################################

    _refreshEnabled: ->
        if @model.id in c.requiredMods
            @hide @$toggleSection
        else
            @show @$toggleSection

        if not @model.isEnabled
            @$toggleSection.removeClass "enabled"
            @show @$warning
        else
            @$toggleSection.addClass "enabled"
            @hide @$warning
