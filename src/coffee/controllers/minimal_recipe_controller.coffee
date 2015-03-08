###
Crafting Guide - minimal_recipe_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController         = require './base_controller'
CraftingGridController = require './crafting_grid_controller'
{Duration}             = require '../constants'
ImageLoader            = require './image_loader'
StringBuilder          = require '../models/string_builder'

########################################################################################################################

module.exports = class MinimalRecipeController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'minimal_recipe'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, '.view__crafting_grid',
            modPack:     @modPack
            imageLoader: @imageLoader

        @$outputImg      = @$('.output img')
        @$outputLink     = @$('.output a')
        @$outputQuantity = @$('.quantity')
        @$toolContainer  = @$('.tool')
        super

    refresh: ->
        @gridController.model = @model

        @$outputImg.attr 'src', '/images/empty.png'
        @$outputImg.removeAttr 'alt'
        @$outputLink.removeAttr 'href'
        @$outputQuantity.html ''

        if @model?
            outputStack = @model.output[0]
            if outputStack?
                display = @modPack.findItemDisplay outputStack.itemSlug
                @$outputLink.attr 'href', display.itemUrl
                @$outputLink.attr 'title', display.itemName
                @$outputImg.attr 'alt', display.itemName
                @$outputQuantity.html outputStack.quantity if outputStack.quantity > 1

                @imageLoader.load display.iconUrl, @$outputImg

        @$el.tooltip show:{delay:Duration.snap, duration:Duration.fast}

        @_refreshTools()
        super

    # Backbone.View Methods ########################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshTools: ->
        @$toolContainer.empty()
        return unless @model?

        builder = new StringBuilder
        builder.loop @model.tools, delimiter:', ', onEach:(b, stack)=>
            display = @modPack.findItemDisplay stack.itemSlug
            b.push "<a href=\"#{display.itemUrl}\">#{display.itemName}</a>"
        @$toolContainer.html builder.toString()
