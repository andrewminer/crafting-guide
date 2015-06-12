###
Crafting Guide - minimal_recipe_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController         = require './base_controller'
CraftingGridController = require './crafting_grid_controller'
ImageLoader            = require './image_loader'
SlotController         = require './slot_controller'
_                      = require 'underscore'
{Duration}             = require '../constants'
{StringBuilder}        = require 'crafting-guide-common'

########################################################################################################################

module.exports = class MinimalRecipeController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'minimal_recipe'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack
        @multiplier  = options.multiplier

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, '.view__crafting_grid',
            modPack:     @modPack
            imageLoader: @imageLoader

        @outputSlotController = @addChild SlotController, '.output.view__slot',
            imageLoader: @imageLoader
            modPack:     @modPack

        @$multiplier     = @$('.multiplier')
        @$outputImg      = @$('.output img')
        @$outputLink     = @$('.output a')
        @$outputQuantity = @$('.quantity')
        @$toolContainer  = @$('.tool')
        super

    refresh: ->
        @gridController.model = @model
        @outputSlotController.model = @model?.output?[0]

        @_refreshMultiplier()
        @_refreshTools()
        super

    # Property Methods #############################################################################

    getMultiplier: ->
        @_multiplier ?= 1
        return @_multiplier

    setMultiplier: (newMultiplier)->
        oldMultiplier = @_multiplier
        return if newMultiplier is oldMultiplier

        @_multiplier = newMultiplier
        @_refreshMultiplier()

        @trigger Event.change + ':multiplier', this, oldMultiplier, newMultiplier
        @trigger Event.change, this

    Object.defineProperties @prototype,
        multiplier: {get:@prototype.getMultiplier, set:@prototype.setMultiplier}

    # Backbone.View Methods ########################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshMultiplier: ->
        if @multiplier > 1
            @$multiplier.html "x#{@multiplier}"
        else
            @$multiplier.html ''

    _refreshTools: ->
        @$toolContainer.empty()
        return unless @model?

        builder = new StringBuilder
        builder.loop @model.tools, delimiter:', ', onEach:(b, stack)=>
            display = @modPack.findItemDisplay stack.itemSlug
            b.push "<a href=\"#{display.itemUrl}\">#{display.itemName}</a>"
        @$toolContainer.html builder.toString()
