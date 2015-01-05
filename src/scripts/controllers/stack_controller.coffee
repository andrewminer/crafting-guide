###
Crafting Guide - stack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{ImageUrl} = require '../constants'

########################################################################################################################

module.exports = class StackController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'stack'
        super options

        @modPack = options.modPack
        @_loadImage()

    # Event Methods ################################################################################

    onImageLoaded: ->
        return if @_image.loaded

        logger.trace "#{@constructor.name}.onImageLoaded(#{@_image.src})"
        @_image.loaded = true
        @$image.attr 'src', @_image.src

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$image         = @$('img')
        @$nameField     = @$('.name')
        @$quantityField = @$('.quantity')
        super

    refresh: ->
        {itemName} = @_gatherData()
        @$nameField.html itemName
        @$quantityField.html @model.quantity
        @$image.attr 'src', (if @_image?.loaded then @_image.src else '/images/unknown.png')
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

    _loadImage: ->
        {itemSlug, modSlug} = @_gatherData()
        url = ImageUrl(modSlug:modSlug, itemSlug:itemSlug)
        return if @$image?.attr('src').indexOf(url) is -1

        @_image = new Image()
        @_image.loaded = false
        @_image.onload = => @onImageLoaded()
        @_image.src = url
        logger.verbose "loading image: #{url}"
