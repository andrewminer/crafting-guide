#
# Crafting Guide - steps_evaluator.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Evaluator = require './evaluator'

########################################################################################################################

module.exports = class StepsEvaluator extends Evaluator

    # Evaluator Overrides ##########################################################################

    _computeRecipeScore: (recipe, evaluation)->
        evaluation.score = 0

        for id, stack of recipe.inputs
            inputEvaluation = @evaluateItem stack.item
            if not inputEvaluation?.score?
                evaluation.score = null
                return

            evaluation.score = Math.min evaluation.score, inputEvaluation.score + 1

        for id, item of recipe.tools
            continue if evaluation.isToolIncluded item

            toolEvaluation = @evaluateItem stack.item
            if not toolEvaluation?.score?
                evaluation.score = null
                return

            evaluation.addIncludedTool item
            evaluation.score += toolEvaluation.score

        return result

    _computeGatherableItemScore: (item, evaluation)->
        evaluation.score = 0
