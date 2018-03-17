#
# Crafting Guide - item_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ItemParserExtensionV1 = require './item_pe_v1'
ParserData            = require '../parser_data'

########################################################################################################################

parser = data = null

########################################################################################################################

describe 'item_pe_v1.coffee', ->

    beforeEach ->
        data = new ParserData
        parser = new ItemParserExtensionV1 data

        data.create {}, 'modVersion', 0

    describe 'gatherable', ->

        it 'assigns to the current item', ->
            data.create {}, 'item', 1

            parser.execute name:'gatherable', argText:'yes'
            data.getCurrent('item').gatherable.should.be.true
            data.errors.should.eql []

    describe 'item', ->

        it 'creates a new item', ->
            data.create {}, 'itemGroup', 2

            parser.execute name:'item', argText:'alpha'
            item = data.getCurrent 'item'
            item.id.should.equal 'alpha'
            item.isUpdate.should.equal false
            item.name.should.equal 'alpha'
            item.modVersion.id.should.equal 0
            item.group.id.should.equal 2
            data.getErrors().should.eql []

    describe 'update', ->

        it 'creates an item update', ->
            parser.execute name:'update', argText:'alpha'
            item = data.getCurrent 'item'
            item.isUpdate.should.equal true
            data.getErrors().should.eql []