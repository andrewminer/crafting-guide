###
Crafting Guide - crafting_grid.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
util      = require 'util'

########################################################################################################################

module.exports = class CraftingGrid extends BaseModel

    @SLOT_COUNT = 9

    constructor: (attributes={}, options={})->
        if not attributes.modPack? then throw new Error 'attributes.modPack is required'
        attributes.recipe ?= null
        super attributes, options

    Object.defineProperty @prototype, 'slotCount', get:-> CraftingGrid.SLOT_COUNT

    # Public Methods ###############################################################################

    getItemDataAt: (index)->
        if index >= @slotCount then throw new Error "index (#{index}) must be less than #{@slotCount}"
        return null unless @recipe?

        logger.debug "recipe: #{@recipe}"

        itemSlug = @recipe.getItemSlugAt index
        return null unless itemSlug?

        item = @modPack.findItem itemSlug
        if item?
            itemData = item.pathSlugs
            itemData.name = item.name
            return itemData
        else
            return modSlug:'minecraft', itemSlug:itemSlug, name:@modPack.findName(itemSlug)
