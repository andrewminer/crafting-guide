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
        super attributes, options

        @plan.on 'change', => @reset()
        @_step = 0
        @_steps = []

        Object.defineProperties this, {
            hasNextStep: { get:@hasNextStep           }
            hasPrevStep: { get:@hasPrevStep           }
            hasSteps:    { get:@hasSteps              }
            step:        { get:@getStep, set:@setStep }
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

    getStep: ->
        return @_step

    setStep: (newStep)->
        newStep = Math.max 0, Math.min @_steps.length, newStep

        @_step = newStep
        @grid.recipe = @_steps[@_step]?.recipe
        @trigger 'change', this

        return this

    hasSteps: ->
        return @_steps.length > 0

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid}) { plan:#{@plan}, step:#{@_step} }"

    # Private Methods ##############################################################################

    _compactSteps: ->
        @_steps = []
        currentStep = null

        for recipe in @plan.steps
            if currentStep?
                if currentStep.recipe.name is recipe.name
                    currentStep.multiplier += 1
                else
                    currentStep = null

            if not currentStep
                currentStep = multiplier:1, recipe:recipe
                @_steps.push currentStep

        return @_steps
