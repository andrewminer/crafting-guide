#
# Crafting Guide - multiblock.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ItemSlug   = require './item_slug'
Mod        = require './mod'
Multiblock = require './multiblock'
Stack      = require './stack'

########################################################################################################################

describe 'multiblock.coffee', ->

    describe 'with a single block type', ->

        beforeEach ->
            @input = [ new Stack itemSlug:ItemSlug.slugify('cobblestone'), quantity:1 ]

        it 'correctly parses a 1x1x1 cube', ->
            model = new Multiblock input:@input, layers:['0']
            model.depth.should.equal 1
            model.height.should.equal 1
            model.width.should.equal 1
            model.getStackAt(0, 0, 0).toString().should.equal '1 cobblestone'

        it 'correctly parses a solid 3x3x3 cube', ->
            model = new Multiblock input:@input, layers:['000 000 000', '000 000 000', '000 000 000']
            model.depth.should.equal 3
            model.height.should.equal 3
            model.width.should.equal 3

            for x in [0..2]
                for y in [0..2]
                    for z in [0..2]
                        model.getStackAt(x, y, z).toString().should.equal '1 cobblestone'

        it 'correctly parses a hollow 3x3x3 cube', ->
            model = new Multiblock input:@input, layers:['000 000 000', '000 0.0 000', '000 000 000']
            model.depth.should.equal 3
            model.height.should.equal 3
            model.width.should.equal 3

            for x in [0..2]
                for y in [0..2]
                    for z in [0..2]
                        if x isnt 1 or y isnt 1 or z isnt 1
                            model.getStackAt(x, y, z).toString().should.equal '1 cobblestone'
                        else
                            expect(model.getStackAt(x, y, z)).to.be.null

        it 'correctly parses a 3x2x3 pyramid', ->
            model = new Multiblock input:@input, layers:['000 000 000', '.. .0 ..']
            model.depth.should.equal 3
            model.height.should.equal 2
            model.width.should.equal 3

            for y in [0..1]
                for z in [0..2]
                    for x in [0..2]
                        if y is 1 and (x isnt 1 or z isnt 1)
                            expect(model.getStackAt(x, y, z)).to.be.null
                        else
                            model.getStackAt(x, y, z).toString().should.equal '1 cobblestone'

    describe 'with multiple block types', ->

        beforeEach ->
            @input = [
                new Stack itemSlug:ItemSlug.slugify('cobblestone'), quantity:1
                new Stack itemSlug:ItemSlug.slugify('stone'), quantity:1
                new Stack itemSlug:ItemSlug.slugify('oak wood'), quantity:1
            ]

        it 'correctly parses a 1x3x1 column of different types', ->
            model = new Multiblock input:@input, layers:['0', '1', '2']
            model.depth.should.equal 1
            model.height.should.equal 3
            model.width.should.equal 1

            model.getStackAt(0, 0, 0).toString().should.equal '1 cobblestone'
            model.getStackAt(0, 1, 0).toString().should.equal '1 stone'
            model.getStackAt(0, 2, 0).toString().should.equal '1 oak_wood'
