#
# Crafting Guide - parser_state.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserCommand = require './parser_command'
ParserState   = require './parser_state'

########################################################################################################################

command = state = null

########################################################################################################################

describe 'parser_state.coffee', ->

    beforeEach ->
        state   = new ParserState
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

    describe 'each', ->

        it 'ignores the callback when there are no items', ->
            items = []
            state.each (item)-> items.push item
            items.length.should.equal 0

        it 'calls the callback once with a single item', ->
            state.create command, 'alpha', 0
            items = []
            state.each (item)-> items.push item
            items.length.should.equal 1
            items[0].id.should.equal 0

        it 'calls the callback for each item of a single type', ->
            state.create command, 'alpha', 0
            state.create command, 'alpha', 1
            state.create command, 'alpha', 2

            ids = []
            state.each (item)-> ids.push item.id
            ids.should.eql [0, 1, 2]

        it 'calls the callback for each item across multiple types', ->
            state.create command, 'alpha', 0
            state.create command, 'alpha', 1
            state.create command, 'bravo', 0
            state.create command, 'bravo', 1

            ids = []
            state.each (item)-> ids.push "#{item.type}-#{item.id}"
            ids.should.eql ['alpha-0', 'alpha-1', 'bravo-0', 'bravo-1']

    describe 'eachOfType', ->

        it 'ignores the callback if there are no items of that type', ->
            state.create command, 'alpha', 0
            state.create command, 'alpha', 1

            ids = []
            state.eachOfType 'bravo', (item)-> ids.push "#{item.type}-#{item.id}"
            ids.length.should.equal 0

        it 'calls the callback once for each item of the given type', ->
            state.create command, 'alpha', 0
            state.create command, 'alpha', 1
            state.create command, 'bravo', 0
            state.create command, 'bravo', 1

            ids = []
            state.eachOfType 'bravo', (item)-> ids.push "#{item.type}-#{item.id}"
            ids.should.eql ['bravo-0', 'bravo-1']

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
