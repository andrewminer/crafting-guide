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
        attributes.modPack ?= attributes.plan.modPack
        super attributes, options

        @plan.on 'change', => @reset()
        @_step = 0

        Object.defineProperties this, {
            hasNextStep: { get:@hasNextStep           }
            hasPrevStep: { get:@hasPrevStep           }
            hasSteps:    { get:@hasSteps              }
            multiplier:  { get:@getMultiplier         }
            output:      { get:@getOutput             }
            step:        { get:@getStep, set:@setStep }
            stepCount:   { get:@getStepCount          }
            toolNames:   { get:@getToolNames          }
        }

    # Public Methods ###############################################################################

    reset: ->
        @step = 0
        return this

    # Property Methods #############################################################################

    hasNextStep: ->
        return @_step + 1 < @plan.steps.length

    hasPrevStep: ->
        return @_step > 0

    hasSteps: ->
        return @plan.steps.length > 0

    getMultiplier: ->
        step = @plan.steps[@_step]
        return unless step?
        return step.multiplier

    getOutput: ->
        step = @plan.steps[@_step]
        return unless step?
        return step.recipe.output[0]

    getStep: ->
        return @_step

    setStep: (newStep)->
        oldStep = @_step
        newStep = Math.max 0, Math.min @plan.steps.length - 1, newStep

        @_step = newStep
        @grid.recipe = @plan.steps[@_step]?.recipe

        @trigger 'change:step', this, oldStep, newStep
        @trigger 'change', this

        return this

    getStepCount: ->
        return 0 unless @plan.steps?
        return @plan.steps.length

    getToolNames: ->
        recipe = @plan.steps[@_step]?.recipe
        return '' unless recipe?
        toolSlugs = (stack.itemSlug for stack in recipe.tools)
        toolNames = (@modPack.findName(slug) for slug in toolSlugs).join ', '
        return toolNames

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid}) { plan:#{@plan}, step:#{@_step} }"
