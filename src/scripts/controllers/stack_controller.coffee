###
Crafting Guide - stack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{ImageUrl}     = require '../constants'
ImageLoader    = require './image_loader'

########################################################################################################################

module.exports = class StackController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.imageLoader ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.templateName = 'stack'
        super options

        @modPack      = options.modPack
        @_imageLoader = options.imageLoader

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$image         = @$('img')
        @$nameField     = @$('.name')
        @$quantityField = @$('.quantity')
        super

    refresh: ->
        {itemName, itemSlug, modSlug} = @_gatherData()
        imageUrl = ImageUrl itemSlug:itemSlug, modSlug:modSlug

        @$nameField.html itemName
        @$quantityField.html @model.quantity
        @_imageLoader.load imageUrl, @$image
        super

    # Private Methods ##############################################################################

    _gatherData: ->
        itemSlug = @model.itemSlug
        item = @modPack.findItem @model.itemSlug
        if item?
            itemName = item.name
            modSlug = item.modVersion.slug
        else
            itemName = @modPack.findName @model.itemSlug
            modSlug = 'minecraft'

        return itemName:itemName, itemSlug:itemSlug, modSlug:modSlug
