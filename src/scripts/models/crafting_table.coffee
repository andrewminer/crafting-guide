###
# Crafting Guide - crafting_table.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel    = require './base_model'
CraftingPlan = require './crafting_plan'
{Event}      = require '../constants'
Inventory    = require './inventory'

########################################################################################################################

module.exports = class CraftingTable extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.catalog? then throw new Error "attributes.catalog is required"
        attributes.name           ?= null
        attributes.quantity       ?= 1
        attributes.includingTools ?= false
        attributes.have           ?= new Inventory
        attributes.plan           ?= null
        super attributes, options

    # Public Methods ###############################################################################

    craft: ->
        if not @name?.length
            @plan = null
            return

        toolPhrase = if @includingTools then ' includingTools' else ''
        logger.verbose "calculating build plan for #{@quantity} #{@name}#{toolPhrase} with inventory: #{@have}"

        plan = new CraftingPlan @catalog, @includingTools
        plan.includingTools = @includingTools
        plan.craft @name, @quantity, @have

        @plan = plan

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid}) {
            name:#{@name},
            quantity:#{@quantity},
            includingTools:#{@includingTools},
            have:#{@have},
            plan:#{@plan}
        }"
