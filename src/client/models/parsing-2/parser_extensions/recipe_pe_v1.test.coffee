#
# Crafting Guide - recipe_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

RecipeParserExtensionV1 = require './recipe_pe_v1'
ParserState             = require '../parser_state'

########################################################################################################################

parser = state = null

########################################################################################################################

describe 'recipe_pe_v1.coffee', ->

    beforeEach ->
        state = new ParserState
        parser = new RecipeParserExtensionV1 state

        state.create {}, 'item', 0

    describe 'extras', ->

        it 'assigns to the current recipe', ->
            state.create {}, 'recipe'

            parser.execute name:'extras', args:['bravo']
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.extras.should.eql ['bravo']
                    state.errors.should.eql []

    describe 'input', ->

        it 'correctly reads a single item', ->
            state.create {}, 'recipe'

            parser.execute name:'input', args:['bravo']
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.input.should.eql [name:'bravo', quantity:1]
                    state.errors.should.eql []

        it 'correctly reads multiple items', ->
            state.create {}, 'recipe'

            parser.execute name:'input', args:['bravo', 'charlie']
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.input.should.eql [{name:'bravo', quantity:1}, {name:'charlie', quantity:1}]
                    state.errors.should.eql []

        it 'correctly reads a stack', ->
            state.create {}, 'recipe'

            parser.execute name:'input', args:['10 bravo']
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.input.should.eql [name:'bravo', quantity:10]
                    state.errors.should.eql []

    describe 'pattern', ->

        it 'assigns to the current recipe', ->
            state.create {}, 'recipe'

            parser.execute name:'pattern', argText:'00. 00. ...'
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.pattern.should.equal '00. 00. ...'
                    state.errors.should.eql []

        it 'rejects an invalid pattern', ->
            state.create {}, 'recipe'

            parser.execute name:'pattern', argText:'alpha'
                .then ->
                    recipe = state.getCurrent 'recipe'
                    expect(recipe.pattern).to.be.undefined
                    (e.message for e in state.errors).should.eql ['invalid pattern: "alpha"']

    describe 'recipe', ->

        it 'creates a new recipe', ->
            parser.execute name:'recipe'
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.item.id.should.equal 0
                    state.errors.should.eql []

    describe 'quantity', ->

        it 'assigns to the current recipe', ->
            state.create {}, 'recipe'

            parser.execute name:'quantity', argText:'42'
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.quantity.should.equal 42
                    state.errors.should.eql []

    describe 'tools', ->

        it 'assigns to the current recipe', ->
            state.create {}, 'recipe'

            parser.execute name:'tools', args:['bravo']
                .then ->
                    recipe = state.getCurrent 'recipe'
                    recipe.tools.should.eql [name:'bravo', quantity:1]
                    state.errors.should.eql []
