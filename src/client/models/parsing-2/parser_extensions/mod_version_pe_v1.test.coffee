#
# Crafting Guide - mod_version_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ModVersionParserExtensionV1 = require './mod_version_pe_v1'
ParserState                 = require '../parser_state'

########################################################################################################################

parser = state = null

########################################################################################################################

describe 'mod_version_pe_v1.coffee', ->

    beforeEach ->
        state = new ParserState
        parser = new ModVersionParserExtensionV1 state

        state.create {}, 'mod', 0

    describe 'group', ->

        it 'creates a new item group', ->
            state.create {}, 'modVersion', 1

            parser.execute name:'group', argText:'alpha'
                .then ->
                    itemGroup = state.getCurrent('itemGroup')
                    itemGroup.id.should.equal 'alpha'
                    itemGroup.modVersion.id.should.equal 1

    describe 'version', ->

        it 'creates a new mod version', ->
            parser.execute name:'version', argText:'alpha'
                .then ->
                    modVersion = state.getCurrent 'modVersion'
                    modVersion.id.should.equal 'alpha'
                    modVersion.mod.id.should.equal 0
