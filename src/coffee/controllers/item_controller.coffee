###
Crafting Guide - item_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class ItemController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'item'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$icon     = @$('img')
        @$name     = @$('.itemName')
        @$nameLink = @$('a')
        super

    refresh: ->
        display = @_modPack.findItemDisplay @model.slug

        @_imageLoader.load display.iconUrl, @$icon
        @$name.html display.itemName
        @$nameLink.attr 'href', display.itemUrl

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'
