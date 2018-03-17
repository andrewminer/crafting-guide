#
# Crafting Guide - plan_builder.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fixtures    = require './fixtures.test'
PlanBuilder = require './plan_builder'

########################################################################################################################

describe 'plan_builder.coffee', ->

    printPlan = (plan)->
        return '' unless plan?
        return ((s.recipe.slug.replace(/^.*>.*>/, '') for s in plan.steps;;)).join ' > '

    it 'generates an empty plan for a gatherable item', ->
        plans = fixtures.makePlans [1, 'test__oak_wood']

        plans.length.should.equal 1
        plans[0].length.should.equal 0

    it 'can find a multi-step plan', ->
        plans = fixtures.makePlans [1, 'test__lever']

        printPlan(plans[0]).should.equal '4 test__oak_planks > 4 test__stick > test__lever'
        plans.length.should.equal 1

    it 'can find multiple plans', ->
        plans = fixtures.makePlans [1, 'test__iron_ingot']

        printPlan(plans[0]).should.equal '8 test__charcoal > 8 test__iron_ingot'
        printPlan(plans[1]).should.equal '8 test__iron_ingot'
        plans.length.should.equal 2

    it 'ignores invalid plans', ->
        plans = fixtures.makePlans [1, 'test__copper_block']

        printPlan(plans[0]).should.equal '8 test__copper_ingot > test__copper_block'
        printPlan(plans[1]).should.equal '8 test__charcoal > 8 test__copper_ingot > test__copper_block'
        plans.length.should.equal 2
