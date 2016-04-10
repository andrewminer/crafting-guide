#
# Crafting Guide - mod_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ModParserExtensionV1 = require './mod_pe_v1'
ParserState          = require '../parser_state'

########################################################################################################################

parser = state = null

########################################################################################################################

describe 'mod_pe_v1.coffee', ->

    beforeEach ->
        state = new ParserState
        parser = new ModParserExtensionV1 state

        state.create {}, 'mod', 0

    describe 'author', ->

        it 'assigns to the current mod', ->
            parser.execute name:'author', argText:'alpha'
                .then ->
                    state.getCurrent('mod').author.should.equal 'alpha'
                    state.errors.should.eql []

    describe 'downloadUrl', ->

        it 'assigns to the current mod', ->
            parser.execute name:'downloadUrl', argText:'alpha'
                .then ->
                    state.getCurrent('mod').downloadUrl.should.equal 'alpha'
                    state.errors.should.eql []

    describe 'homePageUrl', ->

        it 'assigns to the current mod', ->
            parser.execute name:'homePageUrl', argText:'alpha'
                .then ->
                    state.getCurrent('mod').homePageUrl.should.equal 'alpha'
                    state.errors.should.eql []

    describe 'mod', ->

        it 'creates a new mod', ->
            parser.execute name:'mod', argText:'alpha'
                .then ->
                    mod = state.getCurrent 'mod'
                    mod.id.should.equal 'alpha'
