#
# Crafting Guide - graph_builder.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fixtures = require './fixtures.test'
ItemSlug = require '../game/item_slug'

########################################################################################################################

builder = null

########################################################################################################################

describe 'GraphBuilder.coffee', ->

    beforeEach ->
        builder = fixtures.makeGraphBuilder()

    describe 'expand', ->

        it 'can work a few steps at a time', ->
            builder.want.add ItemSlug.slugify 'test__iron_sword'
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
                builder.want.add ItemSlug.slugify slug
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

            it 'an item with multiple recipes', ->
                runSingleItemTreeBuildingTest 'test__iron_ingot', 6, 11

            it 'an item with multiple inputs and multiple recipes', ->
                runSingleItemTreeBuildingTest 'test__iron_sword', 8, 18

            it 'an item with one recursive recipe', ->
                runSingleItemTreeBuildingTest 'test__copper_ingot', 6, 15

            it 'an item which gatherable and craftable', ->
                runSingleItemTreeBuildingTest 'test__wool', 4, 4

            it 'an item which requires a gatherable and craftable item', ->
                runSingleItemTreeBuildingTest 'test__bed', 6, 7
