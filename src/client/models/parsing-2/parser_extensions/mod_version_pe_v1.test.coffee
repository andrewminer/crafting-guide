#
# Crafting Guide - mod_version_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ModVersionParserExtensionV1 = require './mod_version_pe_v1'
ParserData                  = require '../parser_data'

########################################################################################################################

parser = data = null

########################################################################################################################

describe 'mod_version_pe_v1.coffee', ->

    beforeEach ->
        data   = new ParserData
        parser = new ModVersionParserExtensionV1 data

        data.create {}, 'mod', 0

    describe 'group', ->

        it 'creates a new item group', ->
            data.create {}, 'modVersion', 1

            parser.execute name:'group', argText:'alpha'
            itemGroup = data.getCurrent('itemGroup')
            itemGroup.id.should.equal 'alpha'
            itemGroup.modVersion.id.should.equal 1

    describe 'version', ->

        it 'creates a new mod version', ->
            parser.execute name:'version', argText:'alpha'
            modVersion = data.getCurrent 'modVersion'
            modVersion.id.should.equal 'alpha'
            modVersion.mod.id.should.equal 0
