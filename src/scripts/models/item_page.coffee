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
