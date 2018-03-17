#
# Crafting Guide - mod_tile_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController               = require '../../base_controller'
ModVersionSelectorController = require '../../common/mod_version_selector/mod_version_selector_controller'

########################################################################################################################

module.exports = class ModTileController extends BaseController

    constructor: (options={})->
        options.tagName      = 'section'
        options.templateName = 'browse_page/mod_tile'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @modVersionSelector = @addChild ModVersionSelectorController, '.view__mod_version_selector', model:@model

        @$link        = @$('a')
        @$logoImage   = @$('img')
        @$title       = @$('p.title')
        @$description = @$('p.description')
        super

    refresh: ->
        @$link.attr 'href', c.url.mod modId:@model.id
        @$logoImage.attr 'src', c.url.modIcon modId:@model.id
        @$title.text @model.displayName
        @$description.text @model.description

        if @model.isEnabled
            @$el.removeClass 'disabled'
        else
            @$el.addClass 'disabled'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            'click a': 'routeLinkClick'
