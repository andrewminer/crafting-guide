#
# Crafting Guide - recipe_detail_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController         = require '../../base_controller'
CraftingGridController = require '../../common/crafting_grid/crafting_grid_controller'
Inventory              = require '../../../models/game/inventory'
InventoryController    = require '../../common/inventory/inventory_controller'
{StringBuilder}        = require 'crafting-guide-common'

########################################################################################################################

module.exports = class RecipeDetailController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        options.templateName = 'item_page/recipe_detail'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, '.view__crafting_grid',
            imageLoader: @_imageLoader
            modPack:     @_modPack
            router:      @_router

        @inputController = @addChild InventoryController, '.input .view__inventory',
            editable:    false
            imageLoader: @_imageLoader
            model:       new Inventory
            modPack:     @_modPack
            router:      @_router

        @outputController = @addChild InventoryController, '.output .view__inventory',
            editable:    false
            imageLoader: @_imageLoader
            model:       new Inventory
            modPack:     @_modPack
            router:      @_router

        @$toolContainer = @$('.tool')
        super

    refresh: ->
        if @model?
            @gridController.model = @model
            @_refreshInputs()
            @_refreshOutputs()
            @_refreshTools()
            @show()
        else
            @hide()

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
            display = @_modPack.findItemDisplay stack.itemSlug
            b.push "<a href=\"#{display.itemUrl}\">#{display.itemName}</a>"
        @$toolContainer.html builder.toString()
