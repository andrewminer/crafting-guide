#
# Crafting Guide - mod_pack_json.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fixtures = require "../fixtures"
ModPackJsonFormatter = require "./mod_pack_json_formatter"
ModPackJsonParser = require "./mod_pack_json_parser"

########################################################################################################################

describe "ModPackJsonParser & ModPackJsonFormatter", ->

    beforeEach ->
        @formatter = new ModPackJsonFormatter
        @parser = new ModPackJsonParser

        @modPack = fixtures.createModPack id:"alpha", displayName:"ALPHA"

        @runTest = =>
            @string1 = @formatter.format @modPack
            @string2 = @formatter.format @parser.parse @string1
            @result = @parser.parse @string2

    describe "an empty modpack", ->

        beforeEach -> @runTest()

        it "can survive a round trip", ->
            @string1.should.equal @string2

        it "contains the modpack's own properties", ->
            @result.id.should.equal @modPack.id
            @result.displayName.should.equal @modPack.displayName

        it "doesn't contain a mods list", ->
            expect(@result.mods).to.beUndefined

    describe "a modpack with a single mod", ->

        beforeEach ->
            @mod = fixtures.createMod modPack:@modPack, id:"bravo", displayName:"BRAVO"

        describe "containing only a gatherable item", ->

            beforeEach ->
                @oakWood = fixtures.configureOakWood @mod
                @runTest()

            it "can survive a round trip", ->
                @string1.should.equal @string2

            it "contains the correct mod", ->
                mod = @result.mods[@mod.id]
                mod.displayName.should.equal @mod.displayName

            it "contains the item", ->
                item = @result.mods[@mod.id].items[@oakWood.id]
                item.displayName.should.equal @oakWood.displayName

        describe "containing a multi-step item & it's requirements", ->

            beforeEach ->
                @craftingTable = fixtures.configureCraftingTable @mod
                @oakPlank = fixtures.configureOakPlank @mod
                @runTest()

            it "can survive a round trip", ->
                @string1.should.equal @string2

            it "contains oak planks", ->
                item = @result.mods[@mod.id].items[@oakPlank.id]
                item.displayName.should.equal @oakPlank.displayName

            it "has the recipe for a crafting table", ->
                recipe = @result.mods[@mod.id].items[@craftingTable.id].firstRecipe
                recipe.getInputAt(0, 0).item.id.should.equal @oakPlank.id
                recipe.getInputAt(0, 1).item.id.should.equal @oakPlank.id
                recipe.getInputAt(1, 0).item.id.should.equal @oakPlank.id
                recipe.getInputAt(1, 1).item.id.should.equal @oakPlank.id
                recipe.output.quantity.should.equal 1

        describe "containing a complex item which needs tools & it's requirements", ->

            beforeEach ->
                @cake = fixtures.configureCake @mod
                @runTest()

            it "can survive a round trip", ->
                @string1.should.equal @string2

            it "has the recipe for a cake", ->
                recipe = @result.mods[@mod.id].items[@cake.id].firstRecipe

    describe "a modpack with multiple mods", ->

        beforeEach ->
            @modA = fixtures.createMod modPack:@modPack, id:"bravo", displayName:"BRAVO"
            @modB = fixtures.createMod modPack:@modPack, id:"charlie", displayName:"CHARLIE"

        describe "where items are used in recipes crossing mods", ->

            beforeEach ->
                @stick     = fixtures.configureStick @modA
                @ironIngot = fixtures.configureIronIngot @modA
                @ironSword = fixtures.configureIronSword @modB
                @runTest()

            it "can survive a round trip", ->
                @string1.should.equal @string2

            it "has each item in the correct mod", ->
                @result.mods[@modA.id].items[@ironIngot.id].displayName.should.equal @ironIngot.displayName
                @result.mods[@modB.id].items[@ironSword.id].displayName.should.equal @ironSword.displayName

            it "has the correct recipe for an iron sword", ->
                recipe = @result.mods[@modB.id].items[@ironSword.id].firstRecipe
                recipe.output.item.id.should.equal @ironSword.id
                recipe.output.quantity.should.equal 1
                recipe.getInputAt(1, 0).item.id.should.equal @ironIngot.id
                recipe.getInputAt(1, 1).item.id.should.equal @ironIngot.id
                recipe.getInputAt(1, 2).item.id.should.equal @stick.id
