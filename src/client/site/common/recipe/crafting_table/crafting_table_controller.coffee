#
# Crafting Guide - crafting_table_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController         = require "../../../base_controller"
CraftingGridController = require "../../crafting_grid/crafting_grid_controller"
InventoryController    = require "../../inventory/inventory_controller"
ItemDisplay            = require "../../../../models/site/item_display"
RecipeDisplay          = require "../../../../models/site/recipe_display"
SlotController         = require "../../slot/slot_controller"
{StringBuilder}        = require("crafting-guide-common").util

########################################################################################################################

module.exports = class CraftingTableController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"
        options.templateName = "common/recipe/crafting_table"
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

    # BaseController Overrides #####################################################################

    onDidRender: ->
        options = editable:false, modPack:@_modPack, imageLoader:@_imageLoader, router:@_router

        @_inputController      = @addChild InventoryController,    ".input_inventory .view__inventory",  options
        @_gridController       = @addChild CraftingGridController, ".input_grid .view__crafting_grid",   options
        @_outputSlotController = @addChild SlotController,         ".output_slot .view__slot",           options
        @_outputController     = @addChild InventoryController,    ".output_inventory .view__inventory", options

        @$inputInventorySection  = @$(".input_inventory")
        @$multiplier             = @$(".multiplier")
        @$outputImg              = @$(".output.slot img")
        @$outputInventorySection = @$(".output_inventory")
        @$outputLink             = @$(".output.slot a")
        @$outputQuantity         = @$(".quantity")
        @$outputSlotSection      = @$(".output_slot")
        @$toolContainer          = @$(".tool")
        super

    onWillChangeModel: (oldModel, newModel)->
        if not newModel? then throw new Error "model is required"
        if newModel.constructor isnt RecipeDisplay then throw new Error "model must be a RecipeDisplay"
        return super oldModel, newModel

    refresh: ->
        @_inputController.model      = @model?.getInventory()
        @_gridController.model       = @model?.recipe
        @_outputSlotController.model = @model?.recipe.output
        @_outputController.model     = @model?.getOutputInventory()

        @_refreshMultiplier()
        @_refreshSections()
        @_refreshTools()
        super

    # Backbone.View Methods ########################################################################

    events: ->
        return _.extend super,
            "click a": "routeLinkClick"

    # Private Methods ##############################################################################

    _refreshMultiplier: ->
        if @model.multiplier > 1
            @$multiplier.html "x#{@model.multiplier}"
        else
            @$multiplier.html ""

    _refreshSections: ->
        @$inputInventorySection.css display:(if @model.showInputInventory then "" else "none")
        @$outputInventorySection.css display:(if @model.showOutputInventory then "" else "none")
        @$outputSlotSection.css display:(if @model.showOutputSlot then "" else "none")

    _refreshTools: ->
        @$toolContainer.empty()
        return unless @model?

        toolLinks = []
        for itemId, item of @model.tools
            display = new ItemDisplay item
            toolLinks.push "<a href=\"#{display.url}\">#{display.name}</a>"

        @$toolContainer.html toolLinks.join ", "
