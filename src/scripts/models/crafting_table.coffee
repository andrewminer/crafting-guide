###
# Crafting Guide - crafting_table.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel = require './base_model'
Inventory = require './inventory'

########################################################################################################################

module.exports = class CraftingTable extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.catalog? then throw new Error "attributes.catalog is required"
        super attributes, options

        @have = new Inventory
        @make = new Inventory
        @get = new Inventory

    # Public Methods ###############################################################################

    craft: (name, quantity=1, includingTools=false)->
        toolPhrase = if includingTools then ' includingTools' else ''
        logger.verbose "calculating build plan for #{quantity} #{name}#{toolPhrase} with inventory: #{@have}"
