###
Crafting Guide - recipe_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController         = require './base_controller'
CraftingGridController = require './crafting_grid_controller'
{Duration}             = require '../constants'
ImageLoader            = require './image_loader'

########################################################################################################################

module.exports = class RecipeController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.imageLoader ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.templateName = 'recipe'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, '.view__crafting_grid',
            modPack:     @_modPack
            imageLoader: @_imageLoader

        @$outputImg      = @$('.output img')
        @$outputLink     = @$('.output a')
        @$outputQuantity = @$('.quantity')
        @$tool           = @$('.tool p')
        super

    refresh: ->
        @gridController.model = @model
        @$tool.html @_findToolNames().join ', '

        @$outputImg.attr 'src', '/images/empty.png'
        @$outputImg.removeAttr 'alt'
        @$outputLink.removeAttr 'href'
        @$outputQuantity.html ''

        if @model?
            outputStack = @model.output[0]
            if outputStack?
                display = @_modPack.findItemDisplay outputStack.slug
                @$outputLink.attr 'href', display.itemUrl
                @$outputLink.attr 'title', display.itemName
                @$outputImg.attr 'alt', display.itemName
                @$outputQuantity.html outputStack.quantity if outputStack.quantity > 1

                @_imageLoader.load display.iconUrl, @$outputImg

        @$el.tooltip show:{delay:Duration.fast, duration:Duration.fast}

        super

    # Private Methods ##############################################################################

    _findToolNames: ->
        result = []
        if @model?
            for stack in @model.tools
                name = @_modPack.findName stack.slug
                result.push name if name?
        return result
