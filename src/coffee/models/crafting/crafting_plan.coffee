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
        return "#{@constructor.name}{
            wanted:#{@wanted},
            required:#{@required},
            steps:[#{(step.toString() for step in @steps).join(',')}],
            produced:#{@produced}
            }"

    # Private Methods ##############################################################################

    _computeRequired: ->
        @_required.addInventory @_wanted

        for i in [@_steps.length-1..0] by -1
            recipe = @_steps[i]

            for stack in recipe.output
                while @_required.quantityOf(stack.itemSlug) > 0
                    @_executeRecipe recipe

        @_produced.addInventory @_wanted

    _executeRecipe: (recipe)->
        #console.log "executing: #{recipe}"
        for stack in recipe.input
            @_use stack
        for stack in recipe.output
            @_produce stack

    _produce: (stack)->
        deficit     = @_required.quantityOf stack.itemSlug
        replenished = Math.min deficit, stack.quantity
        surplus     = stack.quantity - replenished

        #console.log "producing #{stack.itemSlug}, surplus: #{surplus}, replenished:#{replenished}"
        @_produced.add stack.itemSlug, surplus
        @_required.remove stack.itemSlug, replenished

    _use: (stack)->
        available = @_produced.quantityOf stack.itemSlug
        consumed  = Math.min stack.quantity, available
        deficit   = stack.quantity - consumed

        #console.log "using #{stack.itemSlug}, consumed: #{consumed}, deficit:#{deficit}"
        @_produced.remove stack.itemSlug, consumed
        @_required.add stack.itemSlug, deficit
