###
Crafting Guide - stack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
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
        display = @modPack.findItemDisplay @model.itemSlug

        @$nameField.html display.itemName
        @$quantityField.html @model.quantity
        @_imageLoader.load display.iconUrl, @$image
        super
