#
# Crafting Guide - resources_evaluator.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ResourcesEvaluator = require './resources_evaluator'
fixtures           = require './fixtures'

########################################################################################################################

describe "ResourcesEvaluator", ->

    beforeEach ->
        @evaluator = new ResourcesEvaluator
        @mod = fixtures.createMod()

    describe 'evaluating a gatherable item', ->

        beforeEach ->
            @cobblestone = fixtures.configureCobblestone @mod
            @evaluation = @evaluator.evaluateItem @cobblestone

        it 'should return a score of 1 for each item', ->
            # 1 cobblestone
            @evaluation.computeTotalScore().should.equal 1

    describe 'evaluating a first-level recipe', ->

        beforeEach ->
            @craftingTable = fixtures.configureCraftingTable @mod
            @evaluation = @evaluator.evaluateItem @craftingTable

        it 'should return a score which is the sum of all resources', ->
            # 1 oak wood => 4 planks (1/4)
            # 4 oak planks => 1 crafting table (4 * 1/4 = 1)
            @evaluation.computeTotalScore().should.equal 1

    describe 'evaluating a recipe which requires a tool', ->

        beforeEach ->
            @furnace = fixtures.configureFurnace @mod
            @evaluation = @evaluator.evaluateItem @furnace

        it 'includes the cost of the tool', ->
            # 1 oak wood => 4 planks (1/4)
            # 4 oak planks => 1 crafting table (4 * 1/4 = 1)
            # 8 cobblestone =(crafting table)=> 1 furnace (8 + 1 = 9)
            @evaluation.computeTotalScore().should.equal 9

    describe 'evaluating a recipe where a tool requires a tool', ->

        beforeEach ->
            @ironIngot = fixtures.configureIronIngot @mod
            @evaluation = @evaluator.evaluateItem @ironIngot

        it 'should include both tools in the score', ->
            # raw ingredients:
            #     8 iron ore + 1 coal =(furnace)=> 8 iron ingots ((8 + 1) / 8 = 1.125)
            # tools:
            #     8 cobblestone =(crafting table)=> 1 furnace (8)
            #     4 oak planks => 1 crafting table (4 * 1/4 = 1)
            #         1 oak wood => 4 planks (1/4)
            @evaluation.computeTotalScore().should.equal 10.125

    describe 'evaluating a recipe which requires a tool multiple times', ->

        beforeEach ->
            @ironSword = fixtures.configureIronSword @mod
            @evaluation = @evaluator.evaluateItem @ironSword

        it 'should include the tool only once', ->
            # raw ingredients:
            #     1 oak wood ==> 4 planks (0.25)
            #     2 oak planks ==> 4 sticks (0.125)
            #     8 iron ore + 1 coal =(furnace)=> 8 iron ingots (1.125)
            #     2 iron ingot + 1 stick =(crafting table)=> 1 iron sword (2.375)
            #
            # tools:
            #     8 cobblestone =(crafting table)=> 1 furnace (8)
            #
            #     1 oak wood => 4 planks (0.25)
            #     4 oak planks => 1 crafting table (1)
            #
            @evaluation.computeTotalScore().should.equal 11.375

    describe 'evaluating a recipe which has a recursive recipe', ->

        beforeEach ->
            @ironBlock = fixtures.configureIronBlock @mod
            @evaluation = @evaluator.evaluateItem @ironBlock

        it 'should avoid the recursive recipes', ->
            # raw ingredients:
            #     8 iron ore + 1 coal =(furnace)=> 8 iron ingots ((8 + 1) / 8 = 1.125)
            #     9 iron ingot =(crafting table)=> 1 iron block (10.125)
            #
            # tools:
            #     8 cobblestone =(crafting table)=> 1 furnace (8)
            #     4 oak planks => 1 crafting table (4 * 1/4 = 1)
            #         1 oak wood => 4 planks (1/4)
            @evaluation.computeTotalScore().should.equal 19.125

    describe 'evaluating a recipe with multiple ouputs', ->

        beforeEach ->
            @cake = fixtures.configureCake @mod
            @evaluation = @evaluator.evaluateItem @cake

        it 'should discount the extra outputs', ->
            # raw ingredients:
            #    8 iron ore + 1 coal =(furnace)=> 8 iron ingot (1.125)
            #    3 iron ingot =(crafting table)=> 1 bucket (3.375)
            #    1 milk + 1 bucket ==> 1 milk bucket (4.375)
            #    1 sugar cane ==> 1 sugar (1)
            #    3 wheat + 1 egg + 2 sugar + 3 milk bucket =(crafting table)=> 1 cake, 3 buckets (9)
            #
            # furnace:
            #    8 cobblestone =(crafting table)=> 1 furnace (8)
            #
            # crafting table
            #    1 oak wood ==> 4 oak planks (0.25)
            #    4 planks ==> 1 crafting table (1)
            @evaluation.computeTotalScore().should.equal 18
