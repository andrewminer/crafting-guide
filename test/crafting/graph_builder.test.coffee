###
Crafting Guide - crafting_node.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

GraphBuilder = require '../../src/coffee/models/crafting/graph_builder'
ItemSlug     = require '../../src/coffee/models/item_slug'
Mod          = require '../../src/coffee/models/mod'
ModPack      = require '../../src/coffee/models/mod_pack'
ModVersion   = require '../../src/coffee/models/mod_version'

########################################################################################################################

SAMPLE_MOD_VERSION_TEXT = """
    schema: 1

    item: Charcoal
        recipe:
            input: 8 Oak Wood, Coal
            pattern: .0. ... .1.

    item: Crafting Table
        recipe:
            input: Oak Planks
            pattern: .00 .00 ...

    item: Coal

    item: Cobblestone

    item: Furnace
        recipe:
            input: Cobblestone
            pattern: 000 0.0 000
            tools: Crafting Table

    item: Iron Ore

    item: Iron Ingot
        recipe:
            input: 8 Iron Ore, Charcoal
            pattern: .0. ... .1.
            tools: Furnace
        recipe:
            input: 8 Iron Ore, Coal
            pattern: .0. ... .1.
            tools: Furnace

    item: Iron Sword
        recipe:
            input: Iron Ingot, Stick
            pattern: .0. .0. .1.
            tools: Crafting Table

    item: Lever
        recipe:
            input: Stick, Cobblestone
            pattern: .0. .1. ...

    item: Oak Planks
        recipe:
            input: Oak Wood
            pattern: ... .0. ...
            quantity: 4

    item: Oak Wood

    item: Stick
        recipe:
            input: Oak Planks
            pattern: .0. .0. ...
            quantity: 4
"""

builder = mod = modPack = modVersion = null

########################################################################################################################

describe.only 'GraphBuilder.coffee', ->

    beforeEach ->
        modPack = new ModPack

        mod = new Mod name:'Test', slug:'test'
        modPack.addMod mod

        modVersion = new ModVersion modSlug:'test', version:'0.0'
        modVersion.parse SAMPLE_MOD_VERSION_TEXT
        mod.addModVersion modVersion

        builder = new GraphBuilder modPack:modPack

    describe 'expand', ->

        it 'can work a few steps at a time', ->
            builder.wanted.add ItemSlug.slugify 'test__iron_sword'
            builder.expandGraph 9

            builder.rootNode.depth.should.equal 6
            builder.rootNode.size.should.equal 13
            builder.complete.should.be.false

            builder.expandGraph 9

            builder.rootNode.depth.should.equal 8
            builder.rootNode.size.should.equal 18
            builder.complete.should.be.true

        it 'works properly with an empty inventory', ->
            builder.expandGraph 100

            builder.rootNode.depth.should.equal 1
            builder.rootNode.size.should.equal 1
            builder.complete.should.be.true

        describe 'can build a tree for', ->

            runSingleItemTreeBuildingTest = (slug, depth, size)->
                builder.wanted.add ItemSlug.slugify slug
                builder.expandGraph 100

                builder.rootNode.depth.should.equal depth
                builder.rootNode.size.should.equal size
                builder.complete.should.be.true

            it 'a gatherable item', ->
                runSingleItemTreeBuildingTest 'test__oak_wood', 2, 2

            it 'a single-step item', ->
                runSingleItemTreeBuildingTest 'test__crafting_table', 6, 6

            it 'an item with multiple inputs', ->
                runSingleItemTreeBuildingTest 'test__lever', 8, 9

            it 'can make a tree for an item with multiple recipes', ->
                runSingleItemTreeBuildingTest 'test__iron_ingot', 6, 11

            it 'can make a tree for an item with multiple inputs and multiple recipes', ->
                runSingleItemTreeBuildingTest 'test__iron_sword', 8, 18
                logger.debug builder.toString()
