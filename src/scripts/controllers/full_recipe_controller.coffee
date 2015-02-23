###
Crafting Guide - full_recipe_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController           = require './base_controller'
CraftingGridController   = require './crafting_grid_controller'
{Duration}               = require '../constants'
ImageLoader              = require './image_loader'
Inventory                = require '../models/inventory'
InventoryTableController = require './inventory_table_controller'

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
            modPack:     @modPack
            imageLoader: @imageLoader

        @inputController = @addChild InventoryTableController, '.input .view__inventory_table',
            editable:    false
            imageLoader: @imageLoader
            model:       new Inventory
            modPack:     @modPack

        @outputController = @addChild InventoryTableController, '.output .view__inventory_table',
            editable:    false
            imageLoader: @imageLoader
            model:       new Inventory
            modPack:     @modPack

        @$tool = @$('.tool p')
        super

    refresh: ->
        @gridController.model = @model
        @$tool.html @_findToolNames().join ', '

        @$el.tooltip show:{delay:Duration.normal, duration:Duration.normal}

        @_refreshInputs()
        @_refreshOutputs()

        super

    # Backbone.View Methods ########################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _findToolNames: ->
        result = []
        if @model?
            for stack in @model.tools
                item = @modPack.findItem stack.itemSlug
                result.push item.name if item?
        return result

    _refreshInputs: ->
        inputs = @inputController.model
        inputs.clear()

        if @model?
            for stack in @model.input
                inputs.add stack.itemSlug, stack.quantity


    _refreshOutputs: ->
        outputs = @outputController.model
        outputs.clear()

        if @model?
            for stack in @model.output
                outputs.add stack.itemSlug, stack.quantity
