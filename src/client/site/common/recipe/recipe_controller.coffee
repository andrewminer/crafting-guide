#
# Crafting Guide - recipe_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController         = require '../../base_controller'
CraftingGridController = require '../crafting_grid/crafting_grid_controller'
SlotController         = require '../slot/slot_controller'
{StringBuilder}        = require 'crafting-guide-common'

########################################################################################################################

module.exports = class RecipeController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        options.templateName = 'common/recipe'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_multiplier  = options.multiplier
        @_router      = options.router

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_gridController = @addChild CraftingGridController, '.view__crafting_grid',
            modPack:     @_modPack
            imageLoader: @_imageLoader
            router:      @_router

        @_outputSlotController = @addChild SlotController, '.output .view__slot',
            imageLoader: @_imageLoader
            modPack:     @_modPack
            router:      @_router

        @$multiplier     = @$('.multiplier')
        @$outputImg      = @$('.output img')
        @$outputLink     = @$('.output a')
        @$outputQuantity = @$('.quantity')
        @$toolContainer  = @$('.tool')
        super

    refresh: ->
        @_gridController.model = @model
        @_outputSlotController.model = @model?.output?[0]

        @_refreshMultiplier()
        @_refreshTools()
        super

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        multiplier:
            get: ->
                @_multiplier ?= 1
                return @_multiplier

            set: (newMultiplier)->
                oldMultiplier = @_multiplier
                return if newMultiplier is oldMultiplier

                @_multiplier = newMultiplier
                @_refreshMultiplier()

                @trigger Event.change + ':multiplier', this, oldMultiplier, newMultiplier
                @trigger Event.change, this

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
            display = @_modPack.findItemDisplay stack.itemSlug
            b.push "<a href=\"#{display.itemUrl}\">#{display.itemName}</a>"
        @$toolContainer.html builder.toString()
