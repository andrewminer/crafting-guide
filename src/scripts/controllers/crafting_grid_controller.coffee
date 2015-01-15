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
        if not options.model? then throw new Error 'options.model is required'
        options.imageLoader ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.templateName = 'crafting_grid'
        super options

        @_imageLoader = options.imageLoader

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

            display = @model.getItemDisplayAt index
            if display?
                slot.a.removeClass 'empty'
                slot.a.attr 'href', display.itemUrl
                slot.a.attr 'title', display.itemName
                @_imageLoader.load display.iconUrl, slot.img
                slot.img.attr 'alt', display.itemName

        @$el.tooltip show:{delay:Duration.slow, duration:Duration.fast}
        super
