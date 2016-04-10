#
# Crafting Guide - item_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ItemParserExtensionV1 = require './item_pe_v1'
ParserState           = require '../parser_state'

########################################################################################################################

parser = state = null

########################################################################################################################

describe 'item_pe_v1.coffee', ->

    beforeEach ->
        state = new ParserState
        parser = new ItemParserExtensionV1 state

        state.create {}, 'modVersion', 0

    describe 'gatherable', ->

        it 'assigns to the current item', ->
            state.create {}, 'item', 1

            parser.execute name:'gatherable', argText:'yes'
                .then ->
                    state.getCurrent('item').gatherable.should.be.true
                    state.errors.should.eql []

    describe 'item', ->

        it 'creates a new item', ->
            state.create {}, 'itemGroup', 2

            parser.execute name:'item', argText:'alpha'
                .then ->
                    item = state.getCurrent 'item'
                    item.id.should.equal 'alpha'
                    item.name.should.equal 'alpha'
                    item.modVersion.id.should.equal 0
                    item.group.id.should.equal 2
