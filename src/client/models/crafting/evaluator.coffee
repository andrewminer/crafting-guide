#
# Crafting Guide - evaluator.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Evaluation = require './evaluation'

########################################################################################################################

module.exports = class Evaluator

    constructor: ->
        @_id = _.uniqueId "evaluator-"
        @_evaluations = {}

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        id:
            get: -> return @_id
            set: -> throw new Error "id cannot be assigned"

    # Public Methods ###############################################################################

    evaluateItem: (item)->
        return null unless item?

        evaluation = @_evaluations[item.id]
        if not evaluation?
            evaluation = @_evaluations[item.id] = new Evaluation evaluator:this, item:item

            recipeEvaluation = @_findBestRecipeEvaluationFor item
            if recipeEvaluation?
                evaluation.addBaseEvaluation recipeEvaluation
                evaluation.baseScore = recipeEvaluation.baseScore
            else
                @_computeGatherableItemScore item, evaluation

        return evaluation

    evaluateRecipe: (recipe)->
        return null unless recipe?

        evaluation = @_evaluations[recipe.id]
        if not evaluation?
            evaluation = @_evaluations[recipe.id] = new Evaluation evaluator:this, recipe:recipe
            @_computeRecipeScore recipe, evaluation

            for id, toolItem of recipe.tools
                evaluation.addIncludedTool toolItem

                for id, toolItem of @evaluateItem(toolItem).includedTools
                    evaluation.addIncludedTool toolItem


        return evaluation

    getOrderedRecipes: (item, quantity=1)->
        recipes = (recipe for recipeId, recipe of item.recipes)

        recipes.sort (a, b)=>
            scoreA = @evaluateRecipe(a).computeTotalScore quantity
            scoreB = @evaluateRecipe(b).computeTotalScore quantity

            if scoreA isnt scoreB
                return if scoreA < scoreB then -1 else +1

            return 0

        return recipes

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name}<#{@id}>"

    # Overrideable Methods #########################################################################

    _computeRecipeScore: (recipe, evaluation)->
        throw new Error "#{@constructor.name} must override _computeRecipeScore"

    _computeGatherableItemScore: (item, evaluation)->
        throw new Error "#{@constructor.name} must override _computeGatherableItemScore"

    # Private Methods ##############################################################################

    _findBestRecipeEvaluationFor: (item)->
        return null if item.isGatherable
        result = null

        for recipeMap in [item.recipes, item.recipesAsExtra]
            for id, recipe of recipeMap
                evaluation = @evaluateRecipe recipe
                continue unless evaluation?.baseScore?

                if not result? then result = evaluation
                if evaluation.baseScore < result.baseScore then result = evaluation

        return result
