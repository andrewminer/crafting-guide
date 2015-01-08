###
Crafting Guide - crafting_grid_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
ImageLoader    = require './image_loader'
{ImageUrl}     = require '../constants'
util           = require 'util'

########################################################################################################################

module.exports = class CraftingGridController extends BaseController

    @EMPTY_IMAGE = '/images/empty.png'

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.imageLoader ?= new ImageLoader default:'/images/unknown.png'
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
            slot.img.attr 'src', CraftingGridController.EMPTY_IMAGE
            slot.img.removeAttr 'alt'

            itemData = @model.getItemDataAt index
            if itemData?
                slot.a.removeClass 'empty'
                slot.a.attr 'href', "/items/#{encodeURIComponent(itemData.name)}"
                logger.debug "item data: #{util.inspect(itemData)}"
                @_imageLoader.load ImageUrl(itemData), slot.img
                slot.img.attr 'alt', itemData.name
        super
