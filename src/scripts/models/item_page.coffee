###
Crafting Guide - item_page.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel    = require './base_model'
CraftingPlan = require './crafting_plan'
{Event}      = require '../constants'

########################################################################################################################

module.exports = class ItemPage extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.modPack? then throw new Error 'attributes.modPack is required'
        attributes.item ?= null
        super attributes, options

        @_plan = new CraftingPlan modPack:@modPack
        @on Event.change + ':item', => @_updateCraftingPlan()
        @_updateCraftingPlan()

        Object.defineProperties this,
            craftingRawMaterials: {get:-> @_plan.need}
            craftingSteps:        {get:-> @_plan.steps}

    # Property Methods #############################################################################

    findComponentInItems: ->
        return null unless @item?

        result = {}
        @modPack.eachMod (mod)=>
            mod.eachRecipe (recipe)=>
                if recipe.requires @item.slug
                    outputItem = @modPack.findItem recipe.itemSlug
                    result[outputItem.slug] = outputItem

        result = _.values result
        return null unless result.length > 0

        return result.sort (a, b)-> a.compareTo b

    findSimilarItems: ->
        return null unless @item?.modVersion?

        result = []
        @item.modVersion.eachItemInGroup @item.group, (item)=>
            return if item is @item
            result.push item

        return null unless result.length > 0
        return result

    findRecipes: ->
        return @modPack.findRecipes @item?.slug

    # Private Methods ##############################################################################

    _updateCraftingPlan: ->
        @_plan.clear()

        if @item?
            @_plan.want.add @item.slug
            @_plan.craft()

            if @_plan.steps.length > 0
                @_primaryRecipe = @_plan.steps[@_plan.steps.length - 1].recipe
            else
                @_primaryRecipe = null
