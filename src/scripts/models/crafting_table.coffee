###
Crafting Guide - crafting_table.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel    = require './base_model'
CraftingGrid = require './crafting_grid'

########################################################################################################################

module.exports = class CraftingTable extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.plan? then throw new Error "attributes.plan is required"
        attributes.grid ?= new CraftingGrid modPack:attributes.plan.modPack
        attributes.step ?= 0
        super attributes, options

        @plan.on 'change', => @reset()

    # Public Methods ###############################################################################

    reset: ->
        logger.trace "CraftingTable.reset()"

        @step = 0
        @grid.recipe = @plan.steps[0]
        @trigger 'change', this

        return this

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid}) { plan:#{@plan}, step:#{@step} }"
