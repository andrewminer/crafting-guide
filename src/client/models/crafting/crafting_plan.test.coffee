#
# Crafting Guide - crafting_plan.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingPlan = require './crafting_plan'
fixtures     = require './fixtures.test'
ItemSlug     = require '../game/item_slug'

########################################################################################################################

describe 'crafting_plan.coffee', ->

    it 'requires wanted item if gatherable', ->
        plans = fixtures.makePlans [1, 'test__coal']
        plans.length.should.equal 1

        plan = plans[0]
        plan.computeRequired()
        plan.need.unparse().should.equal 'coal'
        plan.made.unparse().should.equal 'coal'

    it 'can compute a single item with one single step plan', ->
        plans = fixtures.makePlans [1, 'test__charcoal']
        plans.length.should.equal 1

        plan = plans[0]
        plan.computeRequired()
        plan.need.unparse().should.equal 'coal:8.oak_wood'
        plan.made.unparse().should.equal '8.charcoal'
        (s.toString() for s in plan.steps).should.eql ['1x 8 test__oak_wood,test__coal>.0. ... .1.>>8 test__charcoal']

    it 'can compute a large quantity of a single item with one single step plan', ->
        plans = fixtures.makePlans [15, 'test__charcoal']
        plans.length.should.equal 1

        plan = plans[0]
        plan.computeRequired()
        plan.need.unparse().should.equal '2.coal:16.oak_wood'
        plan.made.unparse().should.equal '16.charcoal'
        (s.toString() for s in plan.steps).should.eql ['2x 8 test__oak_wood,test__coal>.0. ... .1.>>8 test__charcoal']

    it 'can compute a single item with multiple plans', ->
        plans = fixtures.makePlans [1, 'test__iron_ingot']
        plans.length.should.equal 2

        plan = plans[0]
        plan.computeRequired()
        plan.need.unparse().should.equal 'coal:8.iron_ore:8.oak_wood'
        plan.made.unparse().should.equal '7.charcoal:8.iron_ingot'
        (s.toString() for s in plan.steps).should.eql [
            '1x 8 test__oak_wood,test__coal>.0. ... .1.>>8 test__charcoal'
            '1x 8 test__iron_ore,test__charcoal>.0. ... .1.>test__furnace>8 test__iron_ingot'
        ]

        plan = plans[1]
        plan.computeRequired()
        plan.need.unparse().should.equal 'coal:8.iron_ore'
        plan.made.unparse().should.equal '8.iron_ingot'
        (s.toString() for s in plan.steps).should.eql [
            '1x 8 test__iron_ore,test__coal>.0. ... .1.>test__furnace>8 test__iron_ingot'
        ]

    it 'uses the correct amount of passthrough items', ->
        plans = fixtures.makePlans [10, 'test__split_oak_wood'], [10, 'test__split_spruce_wood']
        plan = plans[2]
        plan.computeRequired()

        plan.need.unparse().should.equal 'coal:8.iron_ore:6.oak_wood:5.spruce_wood'
        plan.made.unparse().should.equal '4.iron_ingot:maul:2.oak_planks:10.split_oak_wood:10.split_spruce_wood:stick'
        (s.toString() for s in plan.steps).should.eql [
            '1x test__oak_wood>... .0. ...>>4 test__oak_planks'
            '1x test__oak_planks>.0. .0. ...>>4 test__stick'
            '1x 8 test__iron_ore,test__coal>.0. ... .1.>test__furnace>8 test__iron_ingot'
            '1x test__iron_ingot,test__stick>001 001 ..1>test__crafting_table>test__maul'
            '5x test__spruce_wood,test__maul>.1. .0. ...>>2 test__split_spruce_wood,test__maul'
            '5x test__oak_wood,test__maul>.1. .0. ...>>2 test__split_oak_wood,test__maul'
        ]

    it 'can compute multiple items with multiple plans', ->
        plans = fixtures.makePlans [1, 'test__copper_block'], [1, 'test__iron_sword']
        plans.length.should.equal 4

        for plan in plans
            plan.computeRequired()
            plan.need.unparse().should.match /16.copper_ore.*8.iron_ore/
            plan.made.unparse().should.match /copper_block.*:iron_sword/

        plan = plans[0]
        plan.need.unparse().should.match /3.coal.*9.oak_wood/
        plan.made.unparse().should.match /7.charcoal/
        "#{plan.steps[3]}".should.equal \
            '1x 8 test__iron_ore,test__charcoal>.0. ... .1.>test__furnace>8 test__iron_ingot'
        "#{plan.steps[4]}".should.equal \
            '2x 8 test__copper_ore,test__coal>.0. ... .1.>test__furnace>8 test__copper_ingot'
        plan.steps.length.should.equal 7

        plan = plans[1]
        plan.need.unparse().should.match /3.coal.*:oak_wood/
        plan.made.unparse().should.not.match /charcoal/
        "#{plan.steps[2]}".should.equal '1x 8 test__iron_ore,test__coal>.0. ... .1.>test__furnace>8 test__iron_ingot'
        "#{plan.steps[3]}".should.equal \
            '2x 8 test__copper_ore,test__coal>.0. ... .1.>test__furnace>8 test__copper_ingot'
        plan.steps.length.should.equal 6

        plan = plans[2]
        plan.need.unparse().should.match /^coal.*9.oak_wood/
        plan.made.unparse().should.match /5.charcoal/
        "#{plan.steps[3]}".should.equal \
            '1x 8 test__iron_ore,test__charcoal>.0. ... .1.>test__furnace>8 test__iron_ingot'
        "#{plan.steps[4]}".should.equal \
            '2x 8 test__copper_ore,test__charcoal>.0. ... .1.>test__furnace>8 test__copper_ingot'
        plan.steps.length.should.equal 7

        plan = plans[3]
        plan.need.unparse().should.match /2.coal.*9.oak_wood/
        plan.made.unparse().should.match /6.charcoal/
        "#{plan.steps[3]}".should.equal '1x 8 test__iron_ore,test__coal>.0. ... .1.>test__furnace>8 test__iron_ingot'
        "#{plan.steps[4]}".should.equal \
            '2x 8 test__copper_ore,test__charcoal>.0. ... .1.>test__furnace>8 test__copper_ingot'
        plan.steps.length.should.equal 7
