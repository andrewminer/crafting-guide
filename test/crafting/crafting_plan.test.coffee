###
Crafting Guide - crafting_plan.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

CraftingPlan = require '../../src/coffee/models/crafting/crafting_plan'
fixtures     = require './fixtures'

########################################################################################################################

describe 'crafting_plan.coffee', ->

    it 'requires wanted item if gatherable', ->
        plans = fixtures.makePlans [1, 'test__coal']
        plans.length.should.equal 1

        plan = plans[0]
        plan.required.unparse().should.equal 'coal'
        plan.produced.unparse().should.equal 'coal'

    it 'can compute a single item with a single step', ->
        plans = fixtures.makePlans [1, 'test__charcoal']
        plans.length.should.equal 1

        plan = plans[0]
        plan.required.unparse().should.equal 'coal:8.oak_wood'
        plan.produced.unparse().should.equal '8.charcoal'

    it 'can compute a large quantity of a single item with a single step', ->
        plans = fixtures.makePlans [15, 'test__charcoal']
        plans.length.should.equal 1

        plan = plans[0]
        plan.required.unparse().should.equal '2.coal:16.oak_wood'
        plan.produced.unparse().should.equal '16.charcoal'

    it 'can compute a single item with multiple steps', ->
        plans = fixtures.makePlans [1, 'test__iron_ingot']
        plans.length.should.equal 2

        plan = plans[0]
        plan.required.unparse().should.equal 'coal:8.iron_ore:8.oak_wood'
        plan.produced.unparse().should.equal '7.charcoal:iron_ingot'

        plan = plans[1]
        plan.required.unparse().should.equal 'coal:8.iron_ore'
        plan.produced.unparse().should.equal 'iron_ingot'
