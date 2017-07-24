#
# Crafting Guide - item_group_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController = require "../../../base_controller"
ItemDisplay    = require "../../../../models/site/item_display"

########################################################################################################################

module.exports = class ItemTileController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.model? then throw new Error "options.model is required"
        options.templateName = "common/item_group/item_tile"
        super options

        @_imageLoader = options.imageLoader
        @_display = new ItemDisplay @model

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$icon     = @$("img")
        @$name     = @$(".itemName")
        @$nameLink = @$("a")
        super

    refresh: ->
        @_imageLoader.load @_display.iconUrl, @$icon
        @$name.html @_display.name
        @$nameLink.attr "href", @_display.url

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            "click a": "routeLinkClick"
