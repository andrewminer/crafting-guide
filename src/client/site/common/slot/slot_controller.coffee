#
# Crafting Guide - slot_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'

########################################################################################################################

module.exports = class SlotController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        # options.model should be a Stack
        options.templateName = 'common/slot'
        options.useAnimations = false
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$link = @$('a')
        @$image = @$('img')
        @$quantity = @$('.quantity')
        super

    refresh: ->
        if @model?
            display = @_modPack.findItemDisplay @model.itemSlug
            @$link.attr 'href', display.itemUrl

            @_imageLoader.load display.iconUrl, @$image

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
