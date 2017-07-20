#
# Crafting Guide - recipe_display.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_            = require "../../../common/underscore"
c            = require "../../../common/constants"
{Inventory}  = require("crafting-guide-common").models
{Observable} = require("crafting-guide-common").util

########################################################################################################################

module.exports = class RecipeDisplay extends Observable

    constructor: (options={})->
        if not options.recipe? then throw new Error "options.recipe is required"
        super

        @_layerInventories = []

        @multiplier          = options.multiplier or 1
        @recipe              = options.recipe
        @showInputInventory  = if options.showInputInventory  then options.showInputInventory  or false
        @showOutputInventory = if options.showOutputInventory then options.showOutputInventory or false
        @showOutputSlot      = if options.showOutputSlot      then options.showOutputSlot      or false

    # Class Methods ################################################################################

    @::RECIPE_TYPE =
        CRAFTING_TABLE: "crafting_table"
        MULTIBLOCK:     "multiblock"

    @::ALL_RECIPE_TYPES = (value for key, value of @::RECIPE_TYPE)

    # Properties ###################################################################################
    
    Object.defineProperties @prototype,

        depth:
            get: -> return @recipe.depth
            set: -> throw new Error "depth cannot be assigned"

        height:
            get: -> return @recipe.height
            set: -> throw new Error "height cannot be assigned"

        multiplier:
            get: -> return @_multiplier
            set: (multiplier)->
                if not _.isNumber(multiplier) then multiplier = 1
                @triggerPropertyChange "multiplier", @_multiplier, multiplier

        recipe:
            get: -> return @_recipe
            set: (recipe)->
                return if recipe is @_recipe
                if not recipe? then throw new Error "recipe is required"
                if @_recipe? then throw new Error "recipe cannot be reassigned"
                @_recipe = recipe
                @_computeType()

        showInputInventory:
            get: -> return @_showInputInventory
            set: (showInputInventory)->
                @triggerPropertyChange "showInputInventory", @_showInputInventory, !!showInputInventory

        showOutputInventory:
            get: -> return @_showOutputInventory
            set: (showOutputInventory)->
                @triggerPropertyChange "showOutputInventory", @_showOutputInventory, !!showOutputInventory

        showOutputSlot:
            get: -> return @_showOutputSlot
            set: (showOutputSlot)->
                @triggerPropertyChange "showOutputSlot", @_showOutputSlot, !!showOutputSlot

        tools:
            get: -> return @recipe.tools
            set: -> throw new Error "tools cannot be assigned"

        type:
            get: -> return @_type
            set: -> throw new Error "type cannot be assigned"

        width:
            get: -> return @recipe.width
            set: -> throw new Error "width cannot be assigned"

    # Public Methods ###############################################################################
    
    getInputAt: (x, y, z)->
        return @recipe.getInputAt x, y, z
    
    getInventory: (z)->
        if not z?
            return @_fullInventory ?= @_createFullInventory()
        else
            return @_layerInventories[z] ?= @_addLayerInventory z

    getOutputInventory: ->
        if not @_outputInventory?
            @_outputInventory = new Inventory
            for stack in @recipe.allProducts
                @_outputInventory.add stack.item, stack.quantity

        return @_outputInventory

    # Private Methods ##############################################################################

    _addLayerInventory: (z, inventory=null)->
        inventory ?= new Inventory
        for x in [0..@recipe.width]
            for y in [0..@recipe.height]
                stack = @recipe.getInputAt x, y, z
                continue unless stack?
                inventory.add stack.item, stack.quantity * @multiplier
        return inventory
    
    _computeType: ->
        if not @recipe?
            type = null
        else if @recipe.depth > 1
            type = @RECIPE_TYPE.MULTIBLOCK
        else
            type = @RECIPE_TYPE.CRAFTING_TABLE
        @triggerPropertyChange "type", @_type, type
    
    _createFullInventory: (inventory=null)->
        inventory ?= new Inventory()
        for z in [0..@recipe.depth]
            @_addLayerInventory z, inventory
        return inventory
