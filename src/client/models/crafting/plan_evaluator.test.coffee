#
# Crafting Guide - plan_evaluator.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingPlan  = require './crafting_plan'
fixtures      = require './fixtures.test'
Inventory     = require '../game/inventory'
PlanEvaluator = require './plan_evaluator'

########################################################################################################################

criteria = evaluator = planA = planB = planC = plans = wanted = null

########################################################################################################################

describe 'plan_evaluator.coffee', ->

    beforeEach ->
        criteria = PlanEvaluator::CRITERIA.FEWEST_STEPS

    describe 'findBestPlan', ->

        it 'can find the shortest of two options', ->
            evaluator = new PlanEvaluator fixtures.makePlans [1, 'test__copper_block']
            evaluator.scorePlans()

            bestPlan = evaluator.findBestPlan criteria
            bestPlan.getScore(criteria).should.equal 1.0

        it 'can find the shortest of many options', ->
            evaluator = new PlanEvaluator fixtures.makePlans [1, 'test__copper_block'], [1, 'test__iron_sword']
            evaluator.scorePlans()

            bestPlan = evaluator.findBestPlan criteria
            bestPlan.getScore(criteria).should.equal 1.0

        it 'can break ties using the non-primary criteria', ->
            evaluator = new PlanEvaluator fixtures.makePlans [2, 'test__iron_ingot'], [1, 'test__charcoal']
            evaluator.scorePlans()

            bestPlan = evaluator.findBestPlan criteria
            bestPlan.getScore(criteria).should.equal 1.0

            (p.getRawScore('fewest steps') for p in evaluator._plans).should.eql [2, 2]
            (p.getRawScore('least materials') for p in evaluator._plans).should.eql [17, 18]

    describe '_normalizeScores', ->

        beforeEach ->
            modPack   = fixtures.makeModPack()
            wanted    = new Inventory modPack:modPack
            have      = new Inventory modPack:modPack
            planA     = new CraftingPlan modPack, wanted, have, []
            planB     = new CraftingPlan modPack, wanted, have, []
            planC     = new CraftingPlan modPack, wanted, have, []
            plans     = [planA, planB, planC]
            evaluator = new PlanEvaluator plans
            criteria  = PlanEvaluator::CRITERIA.FEWEST_STEPS

        it 'does not set scores when none have been evaluated', ->
            evaluator._normalizeScores()
            (plan.hasRawScore(criteria) for plan in plans).should.eql [false, false, false]

        it 'assigns a 1.0 when all plans equal', ->
            for plan in plans
                plan.setRawScore criteria, 5

            evaluator._normalizeScores()
            (plan.getScore(criteria) for plan in plans).should.eql [1.0, 1.0, 1.0]

        it 'computes correct scores from raw scores', ->
            planA.setRawScore criteria, 7
            planB.setRawScore criteria, 8
            planC.setRawScore criteria, 9

            evaluator._normalizeScores()
            (plan.getScore(criteria) for plan in plans).should.eql [1.0, 0.5, 0.0]
