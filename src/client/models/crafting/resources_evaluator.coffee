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

        for row in [0...recipe.height]
            for col in [0...recipe.width]
                stack = recipe.getInputAt row, col
                continue unless stack?

                inputEvaluation = @evaluateItem stack.item
                if inputEvaluation?.baseScore?
                    evaluation.baseScore += inputEvaluation.baseScore * stack.quantity
                    evaluation.addBaseEvaluation inputEvaluation
                else
                    evaluation.baseScore = null
                    logger.outdent()
                    return

        for id, extraStack of recipe.extras
            extraEvaluation = @evaluateItem extraStack.item
            continue unless extraEvaluation?.baseScore?
            evaluation.baseScore -= extraStack.quantity * extraEvaluation.baseScore

        for id, toolItem of recipe.tools
            toolEvaluation = @evaluateItem toolItem
            evaluation.addBaseEvaluation toolEvaluation

        evaluation.baseScore = evaluation.baseScore / recipe.output.quantity

    _computeGatherableItemScore: (item, evaluation)->
        evaluation.baseScore = 1
