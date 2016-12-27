#
# Crafting Guide - mod_pack_json_formatter.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class ModPackJsonParser

    constructor: ->
        @_reset()

    # Public Methods ###############################################################################

    format: (modPack)->
        @_reset()
        return JSON.stringify @_formatModPack modPack

    # Private Methods ##############################################################################

    _formatItem: (item)->
        result = {}
        result.id = item.id
        result.displayName = item.displayName

        if item.isGatherable and item.firstRecipe?
            result.gatherable = true

        return result

    _formatMod: (mod)->
        result = {}
        result.id = mod.id
        result.displayName = mod.displayName

        for itemId, item of mod.items
            result.items ?= []
            @_itemIndexById[item.id] = @_itemIndex++
            result.items.push @_formatItem item

        return result

    _formatModPack: (modPack)->
        result = {}
        result.id = modPack.id
        result.displayName = modPack.displayName

        for modId, mod of modPack.mods
            result.mods ?= []
            result.mods.push @_formatMod mod

        if result.mods?
            for modResult in result.mods
                for itemResult in modResult.items
                    item = modPack.mods[modResult.id].items[itemResult.id]
                    for recipeId, recipe of item.recipesAsPrimary
                        itemResult.recipes ?= []
                        itemResult.recipes.push @_formatRecipe recipe

        return result

    _formatRecipe: (recipe)->
        result = {}
        result.id = recipe.id

        if recipe.output.quantity > 1
            result.quantity = recipe.output.quantity

        result.width = recipe.width
        result.height = recipe.height
        result.depth = recipe.depth if recipe.depth > 1
        result.inputs = []

        for x in [0...recipe.width]
            for y in [0...recipe.height]
                for z in [0...recipe.depth]
                    inputStack = @_formatStack recipe.getInputAt x, y, z
                    result.inputs.push inputStack

        for itemId, stack of recipe.extras
            result.extras ?= []
            result.extras.push @_formatStack stack

        for itemId, item of recipe.tools
            result.tools ?= []
            result.tools.push @_itemIndexById[itemId]

        return result

    _formatStack: (stack)->
        return null unless stack?

        itemIndex = @_itemIndexById[stack.item.id]
        if stack.quantity is 1 then return itemIndex
        return [itemIndex, stack.quantity]

    _reset: ->
        @_itemIndex = 0
        @_itemIndexById = {}
