###
Crafting Guide - crafting_plan.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Inventory = require '../inventory'

########################################################################################################################

module.exports = class CraftingPlan

    constructor: (steps, wanted)->
        if not steps? then throw new Error 'steps is required'
        if not wanted? then throw new Error 'wanted is required'

        @_produced = new Inventory
        @_required = new Inventory
        @_steps    = steps
        @_wanted   = wanted

        @_computeRequired()

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        length:
            get: -> @steps.length
        produced:
            get: -> @_produced
        required:
            get: -> @_required
        steps:
            get: -> @_steps
        wanted:
            get: -> @_wanted

    # Object Overrides #############################################################################

    toString: ->
        result = ["To Make:"]
        @_wanted.each (stack)->
            result.push "    #{stack}"

        result.push "Start with:"
        @_required.each (stack)->
            result.push "    #{stack}"

        result.push "Use these recipes:"
        for step in @_steps
            result.push "    #{step}"

        result.push "To produce:"
        @_produced.each (stack)->
            result.push "    #{stack}"

        return result.join '\n'


    # Private Methods ##############################################################################

    _computeRequired: ->
        @_required.addInventory @_wanted

        for i in [@_steps.length-1..0] by -1
            step = @_steps[i]

            for stack in step.recipe.output
                while @_required.quantityOf(stack.itemSlug) > 0
                    @_executeStep step

        @_produced.addInventory @_wanted

    _executeStep: (step)->
        step.repeat += 1
        recipe = step.recipe

        for stack in recipe.input
            available = @_produced.quantityOf stack.itemSlug
            required  = recipe.getQuantityRequired stack.itemSlug
            consumed  = Math.min required, available
            deficit   = required - consumed

            @_produced.remove stack.itemSlug, consumed
            @_required.add stack.itemSlug, deficit

        for stack in recipe.output
            deficit     = @_required.quantityOf stack.itemSlug
            created     = recipe.getQuantityProduced stack.itemSlug
            replenished = Math.min deficit, created
            surplus     = created - replenished

            @_produced.add stack.itemSlug, surplus
            @_required.remove stack.itemSlug, replenished
