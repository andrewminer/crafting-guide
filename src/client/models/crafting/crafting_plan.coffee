#
# Crafting Guide - crafting_plan.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

SimpleInventory = require './simple_inventory'

########################################################################################################################

module.exports = class CraftingPlan

    constructor: (modPack, want, have, steps)->
        if not modPack? then throw new Error 'modPack is required'
        if not want? then throw new Error 'want is required'
        if not have? then throw new Error 'have is required'
        if not steps? then throw new Error 'steps is required'

        @_have      = have
        @_made      = null
        @_modPack   = modPack
        @_need      = null
        @_rawScores = {}
        @_scores    = {}
        @_steps     = steps
        @_want      = want

        @_numberSteps()

    # Public Methods ###############################################################################

    computeRequired: ->
        @_need = new SimpleInventory modPack:@_modPack
        @_need.addInventory @_want

        @_made = new SimpleInventory modPack:@_modPack
        @_made.addInventory @_have

        for i in [@_steps.length-1..0] by -1
            step = @_steps[i]
            step.multiplier = 0

            for stack in step.recipe.output
                if not stack?
                    throw new Error 'stack should not be null here'

                qualifiedSlug = @_modPack.qualifySlug stack.itemSlug
                while @_need.quantityOf(qualifiedSlug) > 0
                    @_executeStep step

        @_made.addInventory @_want
        @_pruneEmptySteps()
        @_numberSteps()

    hasRawScore: (name)->
        return @_rawScores[name]?

    getRawScore: (name)->
        return @_rawScores[name]

    setRawScore: (name, rawScore)->
        @_rawScores[name] = rawScore

    hasScore: (name)->
        return @_scores[name]?

    getScore: (name)->
        return @_scores[name]

    setScore: (name, score)->
        @_scores[name] = score

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        have:
            get: -> @_have
        length:
            get: -> @steps.length
        made:
            get: -> @_made
        need:
            get: -> @_need
        steps:
            get: -> @_steps
        want:
            get: -> @_want

    # Object Overrides #############################################################################

    toString: ->
        result = ["To Make:"]
        @_want.each (stack)->
            result.push "    #{stack}"

        result.push "When you already have:"
        @_have.each (stack)->
            result.push "    #{stack}"

        result.push "Start with:"
        if @_need?
            @_need.each (stack)->
                result.push "    #{stack}"

        result.push "Use these recipes:"
        for step in @_steps
            result.push "    #{step}"

        result.push "To produce:"
        if @_made?
            @_made.each (stack)->
                result.push "    #{stack}"

        if _.keys(@_rawScores).length > 0
            result.push "Scores:"
            for criteria, score of @_rawScores
                if @_scores[criteria]?
                    result.push "    #{criteria}: #{score} (#{@_scores[criteria]})"
                else
                    result.push "    #{criteria}: #{score}"

        return result.join '\n'

    # Private Methods ##############################################################################

    _executeStep: (step)->
        step.multiplier += 1
        recipe = step.recipe

        for stack in recipe.input
            qualifiedSlug = @_modPack.qualifySlug stack.itemSlug

            available = @_made.quantityOf qualifiedSlug
            required  = recipe.getQuantityRequired stack.itemSlug
            consumed  = Math.min required, available
            deficit   = required - consumed

            @_made.remove qualifiedSlug, consumed
            @_need.add qualifiedSlug, deficit

        for stack in recipe.output
            qualifiedSlug = @_modPack.qualifySlug stack.itemSlug

            deficit     = @_need.quantityOf qualifiedSlug
            created     = recipe.getQuantityProduced stack.itemSlug
            replenished = Math.min deficit, created
            surplus     = created - replenished

            @_made.add qualifiedSlug, surplus
            @_need.remove qualifiedSlug, replenished

    _numberSteps: ->
        for step, i in @_steps
            step.number = i + 1

    _pruneEmptySteps: ->
        index = 0
        while index < @_steps.length
            step = @_steps[index]
            if step.multiplier is 0
                @_steps.splice index, 1
            else
                index++
