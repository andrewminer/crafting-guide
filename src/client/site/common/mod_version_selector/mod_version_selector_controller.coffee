#
# Crafting Guide - mod_version_selector.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'
Mod            = require '../../../models/game/mod'

########################################################################################################################

module.exports = class ModVersionSelectorController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'common/mod_version_selector'
        super options

    # Event Methods ################################################################################

    onToggleEnabled: ->
        if @model.activeVersion is Mod.Version.None
            tracker.trackEvent c.tracking.category.modPack, 'toggle-on', @model.slug
            @model.activeVersion = Mod.Version.Latest
        else
            tracker.trackEvent c.tracking.category.modPack, 'toggle-off', @model.slug
            @model.activeVersion = Mod.Version.None

        return false

    onVersionChanged: ->
        @model.activeVersion = @$versionSelector.val()
        tracker.trackEvent c.tracking.category.modPack, 'select-version', "#{@model.slug}@#{@model.activeVersion}"
        return false

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        effectiveModVersion:
            get: ->
                modVersion = @model.activeModVersion
                modVersion ?= @model.getModVersion Mod.Version.Latest
                modVersion.fetch() if modVersion?
                return modVersion

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$toggleSection   = @$('.toggle')
        @$versionSection  = @$('.version')
        @$versionSelector = @$('.version select')
        @$warning         = @$('.warning')
        super

    refresh: ->
        @_refreshEnabled()
        @_refreshVersionSelector()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'change .version select': 'onVersionChanged'
            'click .toggle':         'onToggleEnabled'

    # Private Methods ##############################################################################

    _refreshEnabled: ->
        if @model.slug in c.requiredMods
            @hide @$toggleSection
        else
            @show @$toggleSection

        if @model.activeVersion is Mod.Version.None
            @$toggleSection.removeClass 'enabled'
            @show @$warning
        else
            @$toggleSection.addClass 'enabled'
            @hide @$warning

    _refreshVersionSelector: ->
        modVersions = @model.modVersions

        if (@model.activeVersion is Mod.Version.None) or modVersions.length < 2
            @hide @$versionSection
        else
            @show @$versionSection

        selectedModVersion = @effectiveModVersion

        @$versionSelector.empty()

        for modVersion in @model.modVersions
            $option = $("<option value=\"#{modVersion.version}\">#{modVersion.version}</option>")
            if modVersion is selectedModVersion
                $option.attr 'selected', 'true'
            @$versionSelector.append $option
        @$versionSelector.css display:''
