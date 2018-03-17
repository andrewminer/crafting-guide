#
# Crafting Guide - current_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CurrentParserExtensionV1 = require './current_pe_v1'
ParserData               = require '../parser_data'

########################################################################################################################

parser = state = null

########################################################################################################################

describe 'current_pe_v1.coffee', ->

    beforeEach ->
        state = new ParserData
        parser = new CurrentParserExtensionV1 state

        state.create {}, 'alpha'

    describe 'description', ->

        it 'assigns to the current object', ->
            parser.execute name:'description', argText:'bravo'
            state.getCurrent().description.should.equal 'bravo'
            state.errors.should.eql []

    describe 'name', ->

        it 'assigns to the current object', ->
            parser.execute name:'name', argText:'bravo'
            state.getCurrent().name.should.equal 'bravo'
            state.errors.should.eql []

    describe 'officialUrl', ->

        it 'assigns to the current object', ->
            parser.execute name:'officialUrl', argText:'bravo'
            state.getCurrent().officialUrl.should.equal 'bravo'
            state.errors.should.eql []

    describe 'video', ->

        it 'assigns to the current object', ->
            parser.execute name:'video', args:['alpha', 'bravo']
            videos = state.getCurrent().videos
            videos[0].youTubeId.should.equal 'alpha'
            videos[0].caption.should.equal 'bravo'
            state.errors.should.eql []

        it 'can assign multiple videos', ->
            parser.execute name:'video', args:['alpha', 'bravo']
            parser.execute name:'video', args:['charlie', 'delta']
            state.getCurrent().videos.length.should.equal 2
            state.errors.should.eql []
