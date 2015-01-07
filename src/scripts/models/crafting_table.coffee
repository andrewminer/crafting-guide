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
        if not attributes.plan? then throw new Error "attributes.plan is required"
        attributes.step ?= 0
        super attributes, options

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid}) { plan:#{@plan}, step:#{@step} }"
