#
# Crafting Guide - crafting_plan.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Inventory       = require "../game/inventory"
{StringBuilder} = require "crafting-guide-common"

########################################################################################################################

module.exports = class CraftingPlan

    constructor: (attributes={})->
        @_id    = _.uniqueId "crafting-plan-"
        @_make  = null
        @_need  = null
        @have   = attributes.have
        @steps  = attributes.steps
        @want   = attributes.want

        @_computeResources()
        @_consolidateSteps()

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        have: # an Inventory specifying what the player already has
            get: -> return @_have
            set: (have)->
                have ?= new Inventory
                if @_have is have then return
                if @_have? then throw new Error "have cannot be reassigned"
                @_have = new Inventory have

        id: # a string uniquely specifying this crafting plan
            get: -> return @_id
            set: -> throw new Error "id is not assignabled"

        make: # an Inventory specifying what the results of executing the plan will be
            get: -> return @_make
            set: -> throw new Error "make cannot be assigned"

        need: # an Inventory specifying what the player will need to gather before executing the plan
            get: -> return @_need
            set: -> throw new Error "need cannot be assigned"

        want: # an Inventory specifying what the player wants to make
            get: -> return @_want
            set: (want)->
                if not want? then throw new Error "want is required"
                if want.isEmpty then throw new Error "want cannot be empty"
                if @_want is want then return
                if @_want? then throw new Error "want cannot be reassigned"
                @_want = new Inventory want

        steps: # an array of CraftingPlanSteps detailing the steps of the plan
            get: -> return @_steps
            set: (steps)->
                steps ?= []
                if steps is @_steps then return
                if @_steps? then throw new Error "steps cannot be reassigned"
                @_steps = steps

    # Object Overrides #############################################################################

    toString: (options={})->
        options.full ?= false

        if options.full
            b = new StringBuilder
            b.line "CraftingPlan<", @_id, ">"
            b.indent()
            b.line "have: ", @_have.toString full:true
            b.line "want: ", @_want.toString full:true
            b.line "need: ", @_need.toString full:true
            b.line "steps:"
            b.indent()
            b.loop @_steps, delimiter:"\n", onEach:(b, step)->
                b.push step.count, " × ", step.recipe.toString(full:true)
            b.line()
            b.outdent()
            b.line "make: ", @_make.toString full:true
            b.outdent()

            return b.toString()
        else
            return "CraftingPlan:#{@_make.toString(full:true)}<#{@_id}>"

    # Private Methods ##############################################################################

    _computeResources: ->
        need = new Inventory @_want
        make = new Inventory @_have
        steps = @_steps[..].reverse()

        for step in steps
            step.count = 0

            for productStack in step.recipe.allProducts
                continue unless need.contains productStack.item
                productCount = Math.ceil need.getQuantity(productStack.item) / productStack.quantity
                step.count = Math.max step.count, productCount

            continue unless step.count > 0

            for itemId, item of step.recipe.inputs
                amountNeeded    = step.count * step.recipe.computeQuantityRequired item
                amountAvailable = make.getQuantity item
                amountUsed      = Math.min amountAvailable, amountNeeded
                amountMissing   = amountNeeded - amountUsed

                make.remove item, amountUsed
                need.add item, amountMissing

            for productStack in step.recipe.allProducts
                amountCreated   = step.count * productStack.quantity
                amountNeeded    = need.getQuantity productStack.item
                amountFulfilled = Math.min amountNeeded, amountCreated
                amountSurplus   = amountCreated - amountFulfilled

                need.remove productStack.item, amountFulfilled
                make.add productStack.item, amountSurplus

        make.merge @_want

        @_make = make
        @_need = need

    _consolidateSteps: ->
        steps = []
        stepsByRecipeId = {}

        for step in @_steps
            priorStep = stepsByRecipeId[step.recipe.id]
            if priorStep?
                priorStep.count += step.count
            else if step.count > 0
                steps.push step
                stepsByRecipeId[step.recipe.id] = step

        @_steps = steps
