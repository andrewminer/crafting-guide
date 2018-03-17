#
# Crafting Guide - plan_evaluator.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class PlanEvaluator

    @::CRITERIA =
        FEWEST_STEPS:    'fewest steps'
        LEAST_MATERIALS: 'least materials'

    constructor: (plans)->
        if not plans? then throw new Error 'plans is required'

        @_plans = plans
        @_lastScored = -1
        @_normalized = false

    # Public Methods ###############################################################################

    findBestPlan: (mainCriteria)->
        criteriaList = [mainCriteria].concat (criteria for key, criteria of @CRITERIA when criteria isnt mainCriteria)
        @_plans.sort (a, b)->
            for criteria in criteriaList
                scoreA = a.getScore criteria
                scoreB = b.getScore criteria

                if scoreA isnt scoreB
                    return if scoreA > scoreB then -1 else +1

            return 0

        return @_plans[0]

    scorePlans: (count)->
        count ?= @_plans.length
        return if @complete

        maxPlanIndex = Math.min @_lastScored + count, @_plans.length - 1
        for i in [(@_lastScored + 1)..maxPlanIndex]
            @_plans[i].computeRequired()
            @_scorePlan @_plans[i]
            @_lastScored = i

        if @complete then @_normalizeScores()

        return @complete

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        complete:
            get: -> @_lastScored is @_plans.length - 1

        lastScored:
            get: -> @_lastScored

    # Private Methods ##############################################################################

    _computeFewestStepsScore: (plan)->
        total = 0
        for step in plan.steps
            total += step.multiplier
        plan.setRawScore @CRITERIA.FEWEST_STEPS, total

    _computeLeastMaterialsScore: (plan)->
        total = 0
        plan.need.each (stack)->
            total += stack.quantity
        plan.setRawScore @CRITERIA.LEAST_MATERIALS, total

    _normalizeScores: ->
        for key, criteria of @CRITERIA
            maxScore  = 0
            minScore  = Number.MAX_VALUE

            for plan in @_plans
                continue unless plan.hasRawScore criteria
                maxScore = Math.max maxScore, plan.getRawScore(criteria)
                minScore = Math.min minScore, plan.getRawScore(criteria)

            adjustedMaxScore = maxScore - minScore
            for plan in @_plans
                continue unless plan.hasRawScore criteria
                if adjustedMaxScore > 0
                    adjustedRawScore = plan.getRawScore(criteria) - minScore
                    plan.setScore criteria, 1.0 - (1.0 * adjustedRawScore / adjustedMaxScore)
                else
                    plan.setScore criteria, 1.0

    _scorePlan: (plan)->
        @_computeFewestStepsScore plan
        @_computeLeastMaterialsScore plan
