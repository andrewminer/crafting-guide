###
Crafting Guide - crafting_table.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel    = require './base_model'
CraftingPlan = require './crafting_plan'
{Event}      = require '../constants'
Inventory    = require './inventory'

########################################################################################################################

module.exports = class CraftingTable extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.modPack? then throw new Error "attributes.modPack is required"
        attributes.name           ?= null
        attributes.quantity       ?= 1
        attributes.includingTools ?= false
        attributes.have           ?= new Inventory
        attributes.plan           ?= null
        super attributes, options

    # Public Methods ###############################################################################

    craft: ->
        if not @modPack.hasRecipe @name
            @plan = null
            return

        toolPhrase = if @includingTools then ' including tools' else ''
        logger.verbose "calculating build plan for #{@quantity} #{@name}#{toolPhrase} with inventory: #{@have}"

        @modPack.enableModsForItem @name

        plan = new CraftingPlan @modPack, @includingTools
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
