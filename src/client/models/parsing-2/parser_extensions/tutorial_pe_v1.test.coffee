#
# Crafting Guide - tutorial_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

TutorialParserExtensionV1 = require './tutorial_pe_v1'
ParserData                = require '../parser_data'

########################################################################################################################

parser = data = null

########################################################################################################################

describe 'tutorial_pe_v1.coffee', ->

    beforeEach ->
        data   = new ParserData
        parser = new TutorialParserExtensionV1 data

        data.create {}, 'modVersion', 1

    describe 'content', ->

        it 'assigns content to the current section', ->
            data.create {}, 'tutorial', 2
            data.create {}, 'section', 3

            parser.execute name:'content', argText:'alpha'
            data.errors.should.eql []
            section = data.getCurrent 'section'
            section.content.should.equal 'alpha'

    describe 'section', ->

        it 'creates a section in the current tutorial', ->
            data.create {}, 'tutorial', 2

            parser.execute name:'section'
            data.errors.should.eql []
            section = data.getCurrent 'section'
            section.tutorial.id.should.equal 2

    describe 'title', ->

        it 'assigns a title to the current tutorial', ->
            data.create {}, 'tutorial', 2
            data.create {}, 'section', 3

            parser.execute name:'title', argText:'alpha'
            data.errors.should.eql []
            section = data.getCurrent 'section'
            section.title.should.equal 'alpha'

    describe 'tutorial', ->

        it 'creates a new tutorial', ->
            parser.execute name:'tutorial', argText:'alpha'
            data.errors.should.eql []
            tutorial = data.getCurrent 'tutorial'
            tutorial.name.should.equal 'alpha'
