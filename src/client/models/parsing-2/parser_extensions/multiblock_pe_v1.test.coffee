#
# Crafting Guide - multiblock_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

MultiblockParserExtensionV1 = require './multiblock_pe_v1'
ParserData                  = require '../parser_data'

########################################################################################################################

parser = data = null

########################################################################################################################

describe 'multiblock_pe_v1.coffee', ->

    beforeEach ->
        data   = new ParserData
        parser = new MultiblockParserExtensionV1 data

        data.create {}, 'item', 1

    describe 'layer', ->

        it 'creates a new layer in the current multiblock', ->
            data.create {}, 'multiblock', 2

            parser.execute name:'layer', argText:'alpha'
            multiblock = data.getCurrent 'multiblock'
            multiblock.layers.length.should.equal 1
            multiblock.layers[0].should.equal 'alpha'

        it 'can create multiple layers', ->
            data.create {}, 'multiblock', 2

            parser.execute name:'layer', argText:'alpha'
            parser.execute name:'layer', argText:'bravo'
            multiblock = data.getCurrent 'multiblock'
            multiblock.layers.should.eql ['alpha', 'bravo']

    describe 'multiblock', ->

        it 'creates a new multiblock', ->
            parser.execute name:'multiblock'
            multiblock = data.getCurrent 'multiblock'
            multiblock.item.id.should.equal 1