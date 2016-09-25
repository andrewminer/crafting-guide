#
# Crafting Guide - plan_builder.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fixtures           = require './fixtures'
Inventory          = require './inventory'
PlanBuilder        = require './plan_builder'
ResourcesEvaluator = require './resources_evaluator'

########################################################################################################################

describe.only "PlanBuilder", ->

    beforeEach ->
        @planner = new PlanBuilder new ResourcesEvaluator
        @mod = fixtures.createMod()
        @want = new Inventory
        @have = new Inventory

    describe "for a gatherable item, creates a plan that", ->

        beforeEach ->
            @oakWood = fixtures.configureOakWood @mod
            @want.add @oakWood, 2
            @plan = @planner.createPlan @want

        it "has no steps at all", ->
            @plan.steps.length.should.equal 0

        it "demands the item itself as the input", ->
            @plan.need.toString(full:true).should.equal "2 Oak Wood"

        it "produces the item as the result", ->
            @plan.make.toString(full:true).should.equal "2 Oak Wood"

    describe "for a single item with a one-step recipe, it creates a plan that", ->

        beforeEach ->
            @oakPlank = fixtures.configureOakPlank @mod
            @want.add @oakPlank, 63
            @plan = @planner.createPlan @want

        it "has the recipe as the only step", ->
            @plan.steps.length.should.equal 1
            @plan.steps[0].recipe.output.item.displayName.should.equal "Oak Planks"

        it "demands the right inputs", ->
            @plan.need.toString(full:true).should.equal "16 Oak Wood"

        it "produces the right results", ->
            @plan.make.toString(full:true).should.equal "64 Oak Planks"

    describe "for a single item with a complex recipe, it creates a plan that", ->

        beforeEach ->
            @ironSword = fixtures.configureIronSword @mod
            @want.add @ironSword, 2
            @plan = @planner.createPlan @want

        it "has the right steps", ->
            @plan.steps.length.should.equal 4
            @plan.steps[0].recipe.output.item.displayName.should.equal "Iron Ingot"
            @plan.steps[1].recipe.output.item.displayName.should.equal "Oak Planks"
            @plan.steps[2].recipe.output.item.displayName.should.equal "Stick"
            @plan.steps[3].recipe.output.item.displayName.should.equal "Iron Sword"

        it "demands the right inputs", ->
            @plan.need.toString(full:true).should.equal "1 Coal, 8 Iron Ore, 1 Oak Wood"

        it "produces the right results", ->
            @plan.make.toString(full:true).should.equal "4 Iron Ingot, 2 Iron Sword, 2 Oak Planks, 2 Stick"

    describe "for multiple items with complex recipes, it creates a plan that", ->

        beforeEach ->
            @ironSword = fixtures.configureIronSword @mod
            @ironShovel = fixtures.configureIronShovel @mod
            @want.add @ironSword, 3
            @want.add @ironShovel, 3
            @plan = @planner.createPlan @want

        it "has consolidated the common steps", ->
            (step.recipe.output.item.displayName for step in @plan.steps).should.eql [
                "Iron Ingot", "Oak Planks", "Stick", "Iron Sword", "Iron Shovel"
            ]

        it "requires the correct repetitions for each step", ->
            (step.count for step in @plan.steps).should.eql [ 2, 2, 3, 3, 3 ]

        it "demands the right inputs", ->
            @plan.need.toString(full:true).should.equal "2 Coal, 16 Iron Ore, 2 Oak Wood"

        it "produces the right results", ->
            @plan.make.toString(full:true).should.equal(
                "7 Iron Ingot, 3 Iron Shovel, 3 Iron Sword, 2 Oak Planks, 3 Stick"
            )

    describe "for an item which has a recursive recipe, it creates a plan that", ->

        beforeEach ->
            @ironBlock = fixtures.configureIronBlock @mod
            @want.add @ironBlock, 4
            @plan = @planner.createPlan @want

        it "avoids the recursive options", ->
            (step.recipe.output.item.displayName for step in @plan.steps).should.eql [
                "Iron Ingot", "Iron Block"
            ]

        it "requires the correct repetitions for each step", ->
            (step.count for step in @plan.steps).should.eql [ 5, 4 ]

        it "demands the right inputs", ->
            @plan.need.toString(full:true).should.equal "5 Coal, 40 Iron Ore"

        it "produces the right results", ->
            @plan.make.toString(full:true).should.equal(
                "4 Iron Block, 4 Iron Ingot"
            )

    describe "when making enormous quantities of something simple", ->

        beforeEach ->
            @oakPlank = fixtures.configureOakPlank @mod
            @want.add @oakPlank, Number.MAX_VALUE / 2
            @start = Date.now()
            @plan = @planner.createPlan @want
            @duration = Date.now() - @start

        it "doesn't take forever to create the plan", ->
            @duration.should.be.lessThan 10

    describe "when making an item which can be made with and without a tool, for a", ->

        beforeEach ->
            @oakPlank = fixtures.configureOakPlank @mod
            @saw = fixtures.configureSaw @mod

        describe "small batch, the plan", ->

            beforeEach ->
                @want.add @oakPlank, 2
                @plan = @planner.createPlan @want

            it "avoids the expensive tool", ->
                (step.recipe.needsTools for step in @plan.steps).should.eql [ false ]

        describe "large batch, the plan", ->

            beforeEach ->
                @want.add @oakPlank, 2048
                @plan = @planner.createPlan @want

            it "uses the tool for efficiency", ->
                (step.recipe.needsTools for step in @plan.steps).should.eql [ true ]
