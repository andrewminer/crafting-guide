###
Crafting Guide - full_recipe_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController         = require './base_controller'
CraftingGridController = require './crafting_grid_controller'
ImageLoader            = require './image_loader'
Inventory              = require '../models/inventory'
InventoryController    = require './inventory_controller'
_                      = require 'underscore'
{Duration}             = require '../constants'
{StringBuilder}        = require 'crafting-guide-common'

########################################################################################################################

module.exports = class FullRecipeController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'full_recipe'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, '.view__crafting_grid',
            imageLoader: @imageLoader
            modPack:     @modPack

        @inputController = @addChild InventoryController, '.input .view__inventory',
            editable:    false
            imageLoader: @imageLoader
            model:       new Inventory
            modPack:     @modPack

        @outputController = @addChild InventoryController, '.output .view__inventory',
            editable:    false
            imageLoader: @imageLoader
            model:       new Inventory
            modPack:     @modPack

        @$toolContainer = @$('.tool')
        super

    refresh: ->
        @gridController.model = @model

        @_refreshInputs()
        @_refreshOutputs()
        @_refreshTools()

        super

    # Backbone.View Methods ########################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshInputs: ->
        inputs = @inputController.model
        inputs.clear()

        if @model?
            for stack in @model.input
                inputs.add stack.itemSlug, @model.getQuantityRequired stack.itemSlug


    _refreshOutputs: ->
        outputs = @outputController.model
        outputs.clear()

        if @model?
            for stack in @model.output
                outputs.add stack.itemSlug, @model.getQuantityProduced stack.itemSlug

    _refreshTools: ->
        @$toolContainer.empty()
        return unless @model?

        builder = new StringBuilder
        builder.loop @model.tools, delimiter:', ', onEach:(b, stack)=>
            display = @modPack.findItemDisplay stack.itemSlug
            b.push "<a href=\"#{display.itemUrl}\">#{display.itemName}</a>"
        @$toolContainer.html builder.toString()
