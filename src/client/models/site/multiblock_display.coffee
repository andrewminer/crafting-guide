#
# Crafting Guide - multiblock_display.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Inventory} = require("crafting-guide-common").models
{Observable} = require("crafting-guide-common").util

########################################################################################################################

module.exports = class MultiblockDisplay extends Observable

    constructor: (recipe)->
        @_layerInventories = []
        @recipe = recipe

    # Properties ###################################################################################
    
    Object.defineProperties @prototype,

        recipe:
            get: -> return @_recipe
            set: (recipe)->
                if not recipe? then throw new Error "recipe is required"
                if @_recipe? then throw new Error "recipe cannot be reassigned"
                @_recipe = recipe

    # Public Methods ###############################################################################
    
    getInventory: (z)->
        if not z?
            return @_fullInventory ?= @_createFullInventory()
        else
            return @_layerInventories[z] ?= @_addLayerInventory z
    
    # Private Methods ##############################################################################

    _addLayerInventory: (z, inventory=null)->
        inventory ?= new Inventory
        for x in [0..@recipe.width]
            for y in [0..@recipe.height]
                stack = @recipe.getInputAt x, y, z
                continue unless stack?
                inventory.add stack.item, stack.quantity
        return inventory
    
    _createFullInventory: (inventory=null)->
        inventory ?= new Inventory()
        for z in [0..@recipe.depth]
            @_addLayerInventory z, inventory
        return inventory
