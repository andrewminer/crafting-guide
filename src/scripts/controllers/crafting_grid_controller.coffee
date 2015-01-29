###
Crafting Guide - crafting_grid_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Duration}     = require '../constants'
ImageLoader    = require './image_loader'

########################################################################################################################

module.exports = class CraftingGridController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.imageLoader ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.templateName = 'crafting_grid'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_slotCount   = 9

    # BaseController Methods #######################################################################

    onDidRender: ->
        @slots = []
        for el in @$('td')
            $el = $(el)
            @slots.push a:$el.find('a'), img:$el.find('img')
        super

    refresh: ->
        for index in [0...@slots.length]
            slot = @slots[index]

            slot.a.addClass 'empty'
            slot.a.removeAttr 'href'
            slot.img.attr 'src', '/images/empty.png'
            slot.img.removeAttr 'alt'

            display = @_getItemDisplayAt index
            if display?
                slot.a.removeClass 'empty'
                slot.a.attr 'href', display.itemUrl
                slot.a.attr 'title', display.itemName
                @_imageLoader.load display.iconUrl, slot.img
                slot.img.attr 'alt', display.itemName

        @$el.tooltip show:{delay:Duration.slow, duration:Duration.fast}
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click td a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _getItemDisplayAt: (slot)->
        if slot >= @_slotCount then throw new Error "slot (#{slot}) must be less than #{@_slotCount}"
        return null unless @model?

        slug = @model.getItemSlugAt slot
        return null unless slug?

        itemDisplay = @_modPack.findItemDisplay slug
        return itemDisplay
