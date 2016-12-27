#
# Crafting Guide - resources_evaluator.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Evaluator = require './evaluator'

########################################################################################################################

module.exports = class ResourcesEvaluator extends Evaluator

    # Evaluator Overrides ##########################################################################

    _computeRecipeScore: (recipe, evaluation)->
        evaluation.baseScore = 0

        for x in [0...recipe.width]
            for y in [0...recipe.height]
                for z in [0...recipe.depth]
                    stack = recipe.getInputAt x, y, z
                    continue unless stack?

                    inputEvaluation = @evaluateItem stack.item
                    if inputEvaluation?.baseScore?
                        evaluation.baseScore += inputEvaluation.baseScore * stack.quantity
                    else
                        evaluation.baseScore = null
                        return

        for id, extraStack of recipe.extras
            extraEvaluation = @evaluateItem extraStack.item
            continue unless extraEvaluation?.baseScore?
            evaluation.baseScore -= extraStack.quantity * extraEvaluation.baseScore

        evaluation.baseScore = evaluation.baseScore / recipe.output.quantity

    _computeGatherableItemScore: (item, evaluation)->
        evaluation.baseScore = 1
