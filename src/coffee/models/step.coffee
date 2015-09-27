###
Crafting Guide - step.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
Inventory = require './inventory'
{Event}   = require '../constants'

########################################################################################################################

module.exports = class Step extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.outputItemSlug? then throw new Error 'attributes.outputItemSlug is required'
        if not attributes.recipe? then throw new Error 'attributes.recipe is required'

        attributes.inventory      = new Inventory
        attributes.number         ?= 1
        attributes.outputItemSlug ?= null
        attributes.multiplier     ?= 1
        attributes.recipe         ?= null
        super attributes, options

        @_computeInventory()
        @on Event.change + ':multiplier', => @_computeInventory()

    # Private Methods ##############################################################################

    _computeInventory: ->
        @inventory.clear()
        for stack in @recipe.input
            @inventory.add stack.itemSlug, stack.quantity * @multiplier
