#
# Crafting Guide - plan_builder.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingPlan     = require "./crafting_plan"
CraftingPlanStep = require "./crafting_plan_step"

########################################################################################################################

module.exports = class PlanBuilder

    constructor: (evaluator)->
        @evaluator = evaluator

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        evaluator:
            get: -> return @_evaluator
            set: (evaluator)->
                if not evaluator? then throw new Error "evaluator is required"
                if @_evaluator is evaluator then return
                if @_evaluator? then throw new Error "evaluator cannot be reassigned"
                @_evaluator = evaluator

    # Public Methods ###############################################################################

    createPlan: (want, have)->
        @_alreadyMaking = {}
        @_recipesInUse = {}

        stepList = []
        for itemId, stack of want.stacks
            steps = @_findStepsForItem stack.item, stack.quantity
            return null unless steps?

            stepList.push steps

        plan = new CraftingPlan want:want, have:have, steps:_.flatten(stepList)
        return plan

    # Private Methods ##############################################################################

    _findStepsForItem: (item, quantity=1)->
        steps = null

        if not @_alreadyMaking[item.id]
            @_alreadyMaking[item.id] = true

            recipes = @_evaluator.getOrderedRecipes item, quantity
            if recipes.length is 0
                steps = []
            else
                for recipe in recipes
                    continue if @_recipesInUse[recipe.id]?

                    steps = @_findStepsForRecipe recipe, quantity
                    break if steps?

            delete @_alreadyMaking[item.id]

        return steps

    _findStepsForRecipe: (recipe, quantity=1)->
        steps = null

        if not @_recipesInUse[recipe.id]
            @_recipesInUse[recipe.id] = true

            invalidRecipe = false
            for itemId, item of recipe.inputs
                inputSteps = @_findStepsForItem item, quantity * recipe.computeQuantityRequired(item)
                if not inputSteps?
                    invalidRecipe = true
                    break

                steps ?= []
                for step in inputSteps
                    steps.push step

            if invalidRecipe
                steps = null
            else
                steps.push new CraftingPlanStep recipe

            delete @_recipesInUse[recipe.id]

        return steps
