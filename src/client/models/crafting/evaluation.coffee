#
# Crafting Guide - evaluation.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class Evaluation

    constructor: (attributes={})->
        @evaluator = attributes.evaluator
        @item      = attributes.item if attributes.item?
        @recipe    = attributes.recipe if attributes.recipe?
        @baseScore = attributes.baseScore

        @_baseEvaluations = []
        @_includedTools = {}
        @_toolScore = null

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        baseEvaluations:
            get: -> return @_baseEvaluations
            set: -> throw new Error "baseEvaluations cannot be assigned"

        baseScore:
            get: -> return @_baseScore
            set: (baseScore)->
                baseScore = parseFloat "#{baseScore}"
                baseScore = if Number.isNaN(baseScore) then null else baseScore
                @_baseScore = baseScore

        evaluator:
            get: -> return @_evaluator
            set: (evaluator)->
                if not evaluator? then throw new Error "evaluator is required"
                if @_evaluator is evaluator then return
                if @_evaluator? then throw new Error "evaluator cannot be reassigned"
                @_evaluator = evaluator

        includedTools:
            get: -> return @_includedTools
            set: -> throw new Error "includedTools cannot be assigned"

        item:
            get: -> return @_item
            set: (item)->
                if @_recipe? then throw new Error "this evaluation is for a recipe: cannot set an item"
                if @_item is item then return
                if not item? then throw new Error "item cannot be assigned null"
                if @_item? then throw new Error "item cannot be reassigned"
                @_item = item

        recipe:
            get: -> return @_recipe
            set: (recipe)->
                if @_item? then throw new Error "this evaluation is for an item: cannot set an recipe"
                if @_recipe is recipe then return
                if not recipe? then throw new Error "recipe cannot be assigned null"
                if @_recipe? then throw new Error "recipe cannot be reassigned"
                @_recipe = recipe

        toolScore:
            get: -> @_computeToolScore()
            set: -> throw new Error "toolScore cannot be assigned"

    # Public Methods ###############################################################################

    addBaseEvaluation: (evaluation)->
        @_baseEvaluations.push evaluation

    addIncludedTool: (item)->
        @_includedTools[item.id] = item
        @_toolScore = null

    computeTotalScore: (quantity=1)->
        if @item?
            multiplier = quantity
        else if @recipe?
            multiplier = Math.ceil 1.0 * quantity / @recipe.output.quantity

        return @baseScore * multiplier + @toolScore

    isToolIncluded: (item)->
        return true if @_includedTools[item.id]?

        for baseEvaluation in @_baseEvaluations
            return true if baseEvaluation.isToolIncluded item

        return false

    # Object Overrides #############################################################################

    toString: ->
        obj = if @item? then @item else @recipe
        return "#{@evaluator}=>#{obj}@#{@baseScore}"

    # Private Methods ##############################################################################

    _computeToolScore: ->
        if not @_toolScore?
            @_toolScore = 0
            for id, toolItem of @_includedTools
                evaluation = @evaluator.evaluateItem toolItem
                continue unless evaluation?.baseScore?
                @_toolScore += evaluation.baseScore

        return @_toolScore
