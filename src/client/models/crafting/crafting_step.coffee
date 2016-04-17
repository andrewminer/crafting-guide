#
# Crafting Guide - crafting_step.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

SimpleInventory = require './simple_inventory'

########################################################################################################################

module.exports = class CraftingStep

    constructor: (recipe, modPack, multiplier=0)->
        if not recipe? then throw new Error 'recipe is required'
        if not modPack? then throw new Error 'modPack is required'
        if multiplier < 0 then throw new Error 'multiplier must be at least 1'

        @number = null

        @_inventory  = null
        @_modPack    = modPack
        @_multiplier = multiplier
        @_recipe     = recipe

    # Public Methods ###############################################################################

    addToolsTo: (targetInventory)->
        for stack in @_recipe.tools
            targetInventory.add stack.itemSlug, stack.quantity

    completeInto: (targetInventory)->
        for stack in @_recipe.output
            continue if @_recipe.isPassThroughFor stack.itemSlug
            quantity = @_recipe.getQuantityProduced stack.itemSlug
            targetInventory.add stack.itemSlug, quantity * @_multiplier

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        inventory:
            get: ->
                if not @_inventory?
                    @_refreshInventory()
                return @_inventory

        recipe:
            get: -> @_recipe

        multiplier:
            get: -> @_multiplier
            set: (newMultiplier)->
                @_multiplier = newMultiplier
                @_refreshInventory() if @_inventory?

        slug:
            get: -> "#{@multiplier}x #{@_recipe.slug}"

    # Object Overrides #############################################################################

    toString: ->
        return @slug

    # Private Methods ##############################################################################

    _refreshInventory: ->
        @_inventory = new SimpleInventory
        for stack in @_recipe.input
            qualifiedSlug = @_modPack.qualifySlug stack.itemSlug
            required = @_recipe.getQuantityRequired(stack.itemSlug) - @_recipe.getQuantityProduced(stack.itemSlug)
            required = if required > 0 then required * @multiplier else 1
            @_inventory.add qualifiedSlug, required
