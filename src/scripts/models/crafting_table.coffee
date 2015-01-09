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
        @_steps = []

        Object.defineProperties this, {
            hasNextStep: { get:@hasNextStep           }
            hasPrevStep: { get:@hasPrevStep           }
            hasSteps:    { get:@hasSteps              }
            multiplier:  { get:@getMultiplier         }
            output:      { get:@getOutput             }
            step:        { get:@getStep, set:@setStep }
            toolNames:   { get:@getToolNames          }
        }

    # Public Methods ###############################################################################

    reset: ->
        @_compactSteps()
        @step = 0

        return this

    # Property Methods #############################################################################

    hasNextStep: ->
        return @_step + 1 < @_steps.length

    hasPrevStep: ->
        return @_step > 0

    hasSteps: ->
        return @_steps.length > 0

    getMultiplier: ->
        step = @_steps[@_step]
        return unless step?
        return step.multiplier

    getOutput: ->
        step = @_steps[@_step]
        return unless step?
        return step.recipe.output[0]

    getStep: ->
        return @_step

    setStep: (newStep)->
        newStep = Math.max 0, Math.min @_steps.length - 1, newStep

        @_step = newStep
        @grid.recipe = @_steps[@_step]?.recipe
        @trigger 'change', this

        return this

    getToolNames: ->
        recipe = @_steps[@_step]?.recipe
        return '' unless recipe?
        toolSlugs = (stack.itemSlug for stack in recipe.tools)
        toolNames = (@modPack.findName(slug) for slug in toolSlugs).join ', '
        return toolNames

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid}) { plan:#{@plan}, step:#{@_step} }"

    # Private Methods ##############################################################################

    _compactSteps: ->
        steps = {}

        for recipe in @plan.steps
            step = steps[recipe.name]
            if not step?
                steps[recipe.name] = multiplier:1, recipe:recipe
            else
                step.multiplier += 1

        @_steps = (step for name, step of steps)
        return this
