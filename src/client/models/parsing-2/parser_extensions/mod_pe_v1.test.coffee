#
# Crafting Guide - mod_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ModParserExtensionV1 = require './mod_pe_v1'
ParserData          = require '../parser_data'

########################################################################################################################

parser = data = null

########################################################################################################################

describe 'mod_pe_v1.coffee', ->

    beforeEach ->
        data   = new ParserData
        parser = new ModParserExtensionV1 data

        data.create {}, 'mod', 0

    describe 'author', ->

        it 'assigns to the current mod', ->
            parser.execute name:'author', argText:'alpha'
            data.getCurrent('mod').author.should.equal 'alpha'
            data.errors.should.eql []

    describe 'documentationUrl', ->

        it 'assigns to the current mod', ->
            parser.execute name:'documentationUrl', argText:'alpha'
            data.getCurrent('mod').documentationUrl.should.equal 'alpha'
            data.errors.should.eql []

    describe 'downloadUrl', ->

        it 'assigns to the current mod', ->
            parser.execute name:'downloadUrl', argText:'alpha'
            data.getCurrent('mod').downloadUrl.should.equal 'alpha'
            data.errors.should.eql []

    describe 'homePageUrl', ->

        it 'assigns to the current mod', ->
            parser.execute name:'homePageUrl', argText:'alpha'
            data.getCurrent('mod').homePageUrl.should.equal 'alpha'
            data.errors.should.eql []

    describe 'mod', ->

        it 'creates a new mod', ->
            parser.execute name:'mod', argText:'alpha'
            mod = data.getCurrent 'mod'
            mod.id.should.equal 'alpha'
