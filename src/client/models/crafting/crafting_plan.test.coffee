#
# Crafting Guide - crafting_plan.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingPlan     = require './crafting_plan'
CraftingPlanStep = require './crafting_plan_step'
Inventory        = require '../game/inventory'
fixtures         = require '../fixtures'

########################################################################################################################

describe "CraftingPlan", ->

    beforeEach ->
        @mod = fixtures.createMod()
        @want = new Inventory
        @have = new Inventory

    describe "with a single step plan", ->

        beforeEach ->
            @oakPlank = fixtures.configureOakPlank @mod
            @want.add @oakPlank, 11

            @plan = new CraftingPlan want:@want, steps:[
                new CraftingPlanStep @oakPlank.firstRecipe
            ]

        it "correctly computes the step counts", ->
            @plan.steps[0].count.should.equal 3

        it "correctly determines the inputs needed", ->
            @plan.need.toString(full:true).should.equal "3 Oak Wood"

        it "correctly computes the products created", ->
            @plan.make.toString(full:true).should.equal "12 Oak Planks"

    describe "with a multi-step plan", ->

        beforeEach ->
            @ironIngot = fixtures.configureIronIngot @mod
            @ironSword = fixtures.configureIronSword @mod
            @oakPlank  = fixtures.configureOakPlank @mod
            @stick     = fixtures.configureStick @mod

            @want.add @ironSword, 20

            @plan = new CraftingPlan want:@want, steps:[
                new CraftingPlanStep @oakPlank.firstRecipe
                new CraftingPlanStep @stick.firstRecipe
                new CraftingPlanStep @ironIngot.firstRecipe
                new CraftingPlanStep @ironSword.firstRecipe
            ]

        it "correctly computes the step counts", ->
            @plan.steps[0].count.should.equal 3
            @plan.steps[1].count.should.equal 5
            @plan.steps[2].count.should.equal 5
            @plan.steps[3].count.should.equal 20

        it "correctly determines the inputs needed", ->
            @plan.need.toString(full:true).should.equal "5 Coal, 40 Iron Ore, 3 Oak Wood"

        it "correctly computes the products created", ->
            @plan.make.toString(full:true).should.equal "20 Iron Sword, 2 Oak Planks"

    describe "with a plan which recycles some items", ->

        beforeEach ->
            @bucket     = fixtures.configureBucket @mod
            @cake       = fixtures.configureCake @mod
            @ironIngot  = fixtures.configureIronIngot @mod
            @milkBucket = fixtures.configureMilkBucket @mod
            @sugar      = fixtures.configureSugar @mod

            @want.add @cake, 2

            @plan = new CraftingPlan want:@want, steps:[
                new CraftingPlanStep @ironIngot.firstRecipe
                new CraftingPlanStep @bucket.firstRecipe
                new CraftingPlanStep @milkBucket.firstRecipe
                new CraftingPlanStep @sugar.firstRecipe
                new CraftingPlanStep @cake.firstRecipe
            ]

        it "correctly computes the step counts", ->
            @plan.steps.length.should.equal 3
            @plan.steps[0].count.should.equal 6
            @plan.steps[1].count.should.equal 4
            @plan.steps[2].count.should.equal 2

        it "correctly determines the inputs needed", ->
            @plan.need.toString(full:true).should.equal "2 Egg, 6 Milk, 4 Sugar Cane, 6 Wheat"

        it "correctly computes the products created", ->
            @plan.make.toString(full:true).should.equal "2 Cake"
