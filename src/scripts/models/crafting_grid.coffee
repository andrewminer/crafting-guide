###
Crafting Guide - crafting_grid.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class CraftingGrid extends BaseModel

    @SLOT_COUNT = 9

    constructor: (attributes={}, options={})->
        if not attributes.modPack? then throw new Error 'attributes.modPack is required'
        attributes.recipe ?= null
        super attributes, options

        Object.defineProperties this,
            'slotCount': { get:-> CraftingGrid.SLOT_COUNT }

    # Public Methods ###############################################################################

    getItemDisplayAt: (slot)->
        if slot >= @slotCount then throw new Error "slot (#{slot}) must be less than #{@slotCount}"
        return null unless @recipe?

        slug = @recipe.getItemSlugAt slot
        return null unless slug?

        itemDisplay = @modPack.findItemDisplay slug
        return itemDisplay
