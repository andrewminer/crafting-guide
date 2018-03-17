#
# Crafting Guide - item_page.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Item}       = require("crafting-guide-common").models
ItemDisplay  = require "./item_display"
{Observable} = require("crafting-guide-common").util

########################################################################################################################

module.exports = class ItemPage extends Observable

    constructor: (item)->
        if item.constructor isnt Item then throw new Error "item must be an Item instance"
        @item = item
        super

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        item:
            get: -> return @_item
            set: (item)->
                if @_item? then throw new Error "item cannot be reassigned"
                if not item? then throw new Error "item is required"
                if @_item? then @_item.off Observable::ANY, this
                @_item = item
                @_item.on Observable::ANY, this, "_onItemChanged"

        itemDisplay:
            get: -> return @_itemDisplay ?= new ItemDisplay @item

        mod:
            get: -> return @_item.mod
            set: -> throw new Error "mod cannot be assigned"

        modPack:
            get: -> return @mod.modPack
            set: -> throw new Error "modPack cannot be assigned"

    # Property Methods #############################################################################

    findComponentInItems: ->
        return @_findItemsWithMatchingRecipes (recipe)=>
            recipe.computeQuantityRequired @item

    findRecipes: ->
        return (recipe for recipeId, recipe of @item.recipes)

    findSimilarItems: ->
        group = @mod.itemGroups[@item.groupName]
        return unless group?

        return null unless group.length > 0
        return group

    findToolForItems: ->
        return @_findItemsWithMatchingRecipes (recipe)=>
            return recipe.tools[@item.id]?

    loadDetails: ->
        stores.itemDetail.loadDetailFor @item
            .catch (error)=>
                if error.message.indexOf("404") is -1
                    logger.error "Could not load details for item #{@item.id}: #{error.message}"
                else
                    logger.info "Item #{@item.id} has no details file."

    # Private Methods ##############################################################################

    _findItemsWithMatchingRecipes: (isMatching)->
        result = {}

        for modId, mod of @modPack.mods
            for itemId, item of mod.items
                for recipeId, recipe of item.recipes
                    if isMatching(recipe)
                        result[item.id] = item

        result = (item for itemId, item of result)
        result.sort (a, b)->
            if not a?.displayName? and not b?.displayName? then return 0
            if not b?.displayName? then return +1
            if not a?.displayName? then return +1
            return a.displayName.localeCompare b.displayName

        return result
    
    _onItemChanged: ->
        @trigger Observable::CHANGE

