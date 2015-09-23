###
Crafting Guide - plan_builder.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

fixtures = require './fixtures'
PlanBuilder = require '../../src/coffee/models/crafting/plan_builder'

########################################################################################################################

describe 'plan_builder.coffee', ->

    printPlan = (plan)->
        return ((s.slug.replace(/^.*>.*>/, '') for s in plan.steps;;)).join ' > '

    it 'generates an empty plan for a gatherable item', ->
        builder = new PlanBuilder fixtures.makeTree 'test__oak_wood'
        plans = builder.producePlans 100

        plans.length.should.equal 1
        plans[0].length.should.equal 0
        builder.complete.should.be.true

    it 'can find a multi-step plan', ->
        builder = new PlanBuilder fixtures.makeTree 'test__lever'
        plans = builder.producePlans 100

        printPlan(plans[0]).should.equal '4 test__oak_planks > 4 test__stick > test__lever'
        plans.length.should.equal 1
        builder.complete.should.be.true

    it 'can find multiple plans', ->
        builder = new PlanBuilder fixtures.makeTree 'test__iron_ingot'
        plans = builder.producePlans 100

        printPlan(plans[0]).should.equal '8 test__charcoal > test__iron_ingot'
        printPlan(plans[1]).should.equal 'test__iron_ingot'
