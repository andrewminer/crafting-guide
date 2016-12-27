#
# Crafting Guide - recipe.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fixtures = require "../fixtures"
Item     = require "./item"
Recipe   = require "./recipe"
Stack    = require "./stack"

########################################################################################################################

describe "Recipe", ->

    beforeEach ->
        @mod       = fixtures.createMod()
        @stick     = fixtures.configureStick @mod
        @ironIngot = fixtures.configureIronIngot @mod
        @obsidian  = fixtures.configureObsidian @mod

        @ironSword = new Item id:"iron_sword", displayName:"Iron Sword", mod:@mod
        @obsidianBox = new Item id:"obsidian_box", displayName:"Obsidian Box", mod:@mod

    describe "getting & setting inputs", ->

        describe "for 2D recipes", ->

            beforeEach ->
                @recipe = new Recipe id:"test1", output:new Stack item:@ironSword
                @recipe.setInputAt 1, 0, new Stack item:@ironIngot
                @recipe.setInputAt 1, 1, new Stack item:@ironIngot
                @recipe.setInputAt 1, 2, new Stack item:@stick

            it "returns assigned values as expected", ->
                expect(@recipe.getInputAt(0, 0)).to.equal null
                @recipe.getInputAt(1, 0).item.displayName.should.equal "Iron Ingot"
                @recipe.getInputAt(1, 1).item.displayName.should.equal "Iron Ingot"
                @recipe.getInputAt(1, 2).item.displayName.should.equal "Stick"
                expect(@recipe.getInputAt(2, 2)).to.equal null

            it "determines the correct dimentions", ->
                @recipe.depth.should.equal 1
                @recipe.height.should.equal 3
                @recipe.width.should.equal 2

        describe "for 3D recipes", ->

            beforeEach ->
                @recipe = new Recipe id:"test2", output:new Stack item:@obsidianBox
                for x in [0..2]
                    for y in [0..2]
                        for z in [0..2]
                            continue if x is 1 and y is 1
                            continue if x is 1 and z is 1
                            continue if y is 1 and z is 1

                            @recipe.setInputAt x, y, z, new Stack item:@obsidian

            it "returns assigned values as expected", ->
                @recipe.getInputAt(0, 0, 0).item.displayName.should.equal "Obsidian"
                @recipe.getInputAt(2, 0, 0).item.displayName.should.equal "Obsidian"
                @recipe.getInputAt(0, 2, 0).item.displayName.should.equal "Obsidian"
                @recipe.getInputAt(2, 2, 2).item.displayName.should.equal "Obsidian"
                expect(@recipe.getInputAt(1, 1, 1)).to.equal null
                expect(@recipe.getInputAt(1, 1, 0)).to.equal null

            it "determines the correct dimentions", ->
                @recipe.depth.should.equal 3
                @recipe.height.should.equal 3
                @recipe.width.should.equal 3