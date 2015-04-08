###
Crafting Guide - slot_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class SlotController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        # options.model should be a Stack
        options.templateName = 'slot'
        options.useAnimations = false
        super options

        @imageLoader = options.imageLoader
        @modPack = options.modPack

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$link = @$('a')
        @$image = @$('img')
        @$quantity = @$('.quantity')
        super

    refresh: ->
        if @model?
            display = @modPack.findItemDisplay @model.itemSlug
            @$link.attr 'href', display.itemUrl

            @imageLoader.load display.iconUrl, @$image

            if @model.quantity > 1
                @$quantity.html @model.quantity
            else
                @$quantity.html ''
        else
            @$link.removeAttr 'href'
            @$quantity.html ''

            @$image.attr 'src', '/images/empty.png'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'
