#
# Crafting Guide - recipe_detail_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController         = require "../../base_controller"
CraftingGridController = require "../../common/crafting_grid/crafting_grid_controller"
{Inventory}            = require("crafting-guide-common").models
InventoryController    = require "../../common/inventory/inventory_controller"
ItemDisplay            = require "../../../models/site/item_display"
{StringBuilder}        = require("crafting-guide-common").util

########################################################################################################################

module.exports = class RecipeDetailController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"
        options.templateName = "item_page/recipe_detail"
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, ".view__crafting_grid",
            imageLoader: @_imageLoader
            modPack:     @_modPack
            router:      @_router

        @inputController = @addChild InventoryController, ".input .view__inventory",
            editable:    false
            imageLoader: @_imageLoader
            model:       new Inventory
            modPack:     @_modPack
            router:      @_router

        @outputController = @addChild InventoryController, ".output .view__inventory",
            editable:    false
            imageLoader: @_imageLoader
            model:       new Inventory
            modPack:     @_modPack
            router:      @_router

        @$toolContainer = @$(".tool")
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
            "click a": "routeLinkClick"

    # Private Methods ##############################################################################

    _refreshInputs: ->
        inputs = @inputController.model
        inputs.clear()
        return unless @model?

        for itemId, item of @model.inputs
            inputs.add item, @model.computeQuantityRequired item

    _refreshOutputs: ->
        outputs = @outputController.model
        outputs.clear()
        return unless @model?

        outputs.add @model.output.item, @model.output.quantity
        for itemId, item of @model.extras
            outputs.add item, @model.computeQuantityProduced item

    _refreshTools: ->
        @$toolContainer.empty()
        return unless @model?

        toolLinks = []
        for itemId, item of @model.tools
            display = new ItemDisplay item
            toolLinks.push "<a href=\"#{display.url}\">#{display.name}</a>"
        @$toolContainer.html toolLinks.join ", "
