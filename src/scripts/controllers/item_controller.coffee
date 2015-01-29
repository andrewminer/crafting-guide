###
Crafting Guide - item_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController         = require './base_controller'
{Url}                  = require '../constants'

########################################################################################################################

module.exports = class ItemController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'item'
        super options

        @_modPack = options.modPack

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$icon     = @$('img')
        @$name     = @$('.itemName')
        @$nameLink = @$('a')
        super

    refresh: ->
        display = @_modPack.findItemDisplay @model.slug

        @$icon.attr 'src', Url.itemIcon display
        @$name.html display.itemName
        @$nameLink.attr 'href', Url.item display
