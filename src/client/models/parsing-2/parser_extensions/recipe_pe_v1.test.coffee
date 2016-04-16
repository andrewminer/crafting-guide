#
# Crafting Guide - recipe_pe_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

RecipeParserExtensionV1 = require './recipe_pe_v1'
ParserData             = require '../parser_data'

########################################################################################################################

parser = data = null

########################################################################################################################

describe 'recipe_pe_v1.coffee', ->

    beforeEach ->
        data = new ParserData
        parser = new RecipeParserExtensionV1 data

        data.create {}, 'item', 0

    describe 'extras', ->

        it 'assigns to the current recipe', ->
            data.create {}, 'recipe'

            parser.execute name:'extras', args:['bravo']
            recipe = data.getCurrent 'recipe'
            recipe.extras.should.eql ['bravo']
            data.errors.should.eql []

    describe 'ignoreDuringCrafting', ->

        it 'assigns to the current recipe', ->
            data.create {}, 'recipe'

            parser.execute name:'ignoreDuringCrafting', argText:'yes'
            recipe = data.getCurrent 'recipe'
            recipe.ignoreDuringCrafting.should.equal true
            data.errors.should.eql []

    describe 'input', ->

        it 'correctly reads a single item', ->
            data.create {}, 'recipe'

            parser.execute name:'input', args:['bravo']
            recipe = data.getCurrent 'recipe'
            recipe.input.should.eql [name:'bravo', quantity:1]
            data.errors.should.eql []

        it 'correctly reads multiple items', ->
            data.create {}, 'recipe'

            parser.execute name:'input', args:['bravo', 'charlie']
            recipe = data.getCurrent 'recipe'
            recipe.input.should.eql [{name:'bravo', quantity:1}, {name:'charlie', quantity:1}]
            data.errors.should.eql []

        it 'correctly reads a stack', ->
            data.create {}, 'recipe'

            parser.execute name:'input', args:['10 bravo']
            recipe = data.getCurrent 'recipe'
            recipe.input.should.eql [name:'bravo', quantity:10]
            data.errors.should.eql []

    describe 'onlyIf', ->

        it 'assigns to the current recipe', ->
            data.create {}, 'recipe'

            parser.execute name:'onlyIf', argText:'not mod Alpha'
            recipe = data.getCurrent 'recipe'
            recipe.condition.should.eql verb:'mod', noun:'Alpha', inverted:true
            data.errors.should.eql []

    describe 'pattern', ->

        it 'assigns to the current recipe', ->
            data.create {}, 'recipe'

            parser.execute name:'pattern', argText:'00. 00. ...'
            recipe = data.getCurrent 'recipe'
            recipe.pattern.should.equal '00. 00. ...'
            data.errors.should.eql []

        it 'rejects an invalid pattern', ->
            data.create {}, 'recipe'

            parser.execute name:'pattern', argText:'alpha'
            recipe = data.getCurrent 'recipe'
            expect(recipe.pattern).to.be.undefined
            (e.message for e in data.errors).should.eql ['invalid pattern: "alpha"']

    describe 'quantity', ->

        it 'assigns to the current recipe', ->
            data.create {}, 'recipe'

            parser.execute name:'quantity', argText:'42'
            recipe = data.getCurrent 'recipe'
            recipe.quantity.should.equal 42
            data.errors.should.eql []

    describe 'recipe', ->

        it 'creates a new recipe', ->
            parser.execute name:'recipe'
            recipe = data.getCurrent 'recipe'
            recipe.item.id.should.equal 0
            data.errors.should.eql []

    describe 'tools', ->

        it 'assigns to the current recipe', ->
            data.create {}, 'recipe'

            parser.execute name:'tools', args:['bravo']
            recipe = data.getCurrent 'recipe'
            recipe.tools.should.eql [name:'bravo', quantity:1]
            data.errors.should.eql []
