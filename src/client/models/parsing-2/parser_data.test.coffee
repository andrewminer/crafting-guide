#
# Crafting Guide - parser_data.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserCommand = require './parser_command'
ParserData   = require './parser_data'

########################################################################################################################

command = state = null

########################################################################################################################

describe 'parser_data.coffee', ->

    beforeEach ->
        state   = new ParserData
        command = new ParserCommand name:'alpha', fileName:'file.cg', lineNumber:1

    describe 'create', ->

        it 'returns an object with the given id', ->
            alpha = state.create command, 'alpha', 0
            alpha.id.should.equal 0
            alpha.command.location.should.equal 'file.cg:1'

        it 'returns an object with a newly created id when none is given', ->
            alpha = state.create command, 'alpha'
            alpha.id.should.not.be.null
            alpha.id.should.match /^alpha-[0-9]+$/
            alpha.command.location.should.equal 'file.cg:1'

    describe 'get', ->

        it 'returns a previously created item', ->
            alpha1 = state.create command, 'alpha', 0
            alpha2 = state.get 'alpha', 0
            alpha1.should.equal alpha2

        it 'returns null when no such item exists', ->
            alpha = state.create command, 'alpha', 0
            expect(state.get 'alpha', 1).to.be.null
            expect(state.get 'bravo', 0).to.be.null

    describe 'getCurrent', ->

        it 'returns the new item each time one is created', ->
            alpha1 = state.create command, 'alpha', 0
            state.getCurrent('alpha').id.should.equal 0

            alpha2 = state.create command, 'alpha', 1
            state.getCurrent('alpha').id.should.equal 1
