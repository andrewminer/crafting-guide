###
Crafting Guide - crafting_table.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Event}   = require '../constants'

########################################################################################################################

module.exports = class CraftingTable extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.plan? then throw new Error "attributes.plan is required"
        super attributes, options

        @plan.on 'change', => @reset()
        @_stepIndex = 0

        Object.defineProperties this, {
            currentStep: { get:@getCurrentStep                  }
            hasNextStep: { get:@hasNextStep                     }
            hasPrevStep: { get:@hasPrevStep                     }
            hasSteps:    { get:@hasSteps                        }
            stepCount:   { get:@getStepCount                    }
            stepIndex:   { get:@getStepIndex, set:@setStepIndex }
        }

    # Public Methods ###############################################################################

    reset: ->
        @stepIndex = 0
        return this

    # Property Methods #############################################################################

    hasNextStep: ->
        return @_stepIndex + 1 < @plan.steps.length

    hasPrevStep: ->
        return @_stepIndex > 0

    hasSteps: ->
        return @plan.steps.length > 0

    getCurrentStep: ->
        return @plan.steps[@_stepIndex]

    getStepIndex: ->
        return @_stepIndex

    setStepIndex: (newStepIndex)->
        oldStepIndex = @_stepIndex
        newStepIndex = Math.max 0, Math.min @plan.steps.length - 1, newStepIndex

        @_stepIndex = newStepIndex

        @trigger Event.change + ':stepIndex', this, oldStepIndex, newStepIndex
        @trigger Event.change, this

        return this

    getStepCount: ->
        return 0 unless @plan.steps?
        return @plan.steps.length

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid}) { plan:#{@plan}, step:#{@_stepIndex} }"
