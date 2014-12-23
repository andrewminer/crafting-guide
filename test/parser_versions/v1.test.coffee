###
# Crafting Guide - v1.test.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

V1 = require '../../src/scripts/models/parser_versions/v1'

########################################################################################################################

parser = null

########################################################################################################################

describe 'RecipeBookParser.V1', ->

    before -> parser = new V1

    describe '_parseRecipeBook', ->

        it 'requires a mod_name', ->
            data = version:1, mod_version:'1.0', recipes:[]
            expect(-> parser._parseRecipeBook data).to.throw Error, 'mod_name is required'

        it 'requires a mod_version', ->
            data = version:1, mod_name:'Empty', recipes:[]
            expect(-> parser._parseRecipeBook data).to.throw Error, 'mod_version is required'

        it 'can parse an empty recipe book', ->
            data =
                version: 1
                mod_name: 'Empty'
                mod_version: '1.0'
                recipes: []
            book = parser._parseRecipeBook data
            book.modName.should.equal 'Empty'
            book.modVersion.should.equal '1.0'

        it 'can parse a non-empty recipe book', ->
            data =
                version: 1
                mod_name: 'Minecraft'
                mod_version: '1.7.10'
                recipes: [
                    { input:'sugar cane', output:'sugar' }
                    { input:[[3, 'wool'], [3, 'planks']], tools:'crafting table', output:'bed' }
                ]
            book = parser._parseRecipeBook data
            book.modName.should.equal 'Minecraft'
            book.modVersion.should.equal '1.7.10'
            (r.name for r in book.recipes).sort().should.eql ['bed', 'sugar']

    describe '_parseRecipe', ->

        it 'requires output to be defined', ->
            parser._errorLocation = 'boat'
            expect(-> parser._parseRecipe input:'wool').to.throw Error, 'boat is missing output'

        it 'requires input to be defined', ->
            parser._errorLocation = 'boat'
            expect(-> parser._parseRecipe output:'wool').to.throw Error, 'boat is missing input'

        it 'can parse a regular recipe', ->
            data =
                output: 'bed'
                input: [[3, 'planks'], [3, 'wool']]
                tools: 'crafting table'
            recipe = parser._parseRecipe data
            (i.name for i in recipe.output).should.eql ['bed']
            (i.name for i in recipe.input).sort().should.eql ['planks', 'wool']
            (i.name for i in recipe.tools).should.eql ['crafting table']

        it 'can parse a recipe without tools', ->
            recipe = parser._parseRecipe output:'sugar', input:'sugar cane'
            (i.name for i in recipe.output).should.eql ['sugar']
            (i.name for i in recipe.input).sort().should.eql ['sugar cane']
            (i.name for i in recipe.tools).should.eql []

    describe '_parseItemList', ->

        it 'can promote a single item to a list', ->
            list = parser._parseItemList 'boat'
            (i.name for i in list).should.eql ['boat']

        it 'can require a list to be non-empty', ->
            parser._errorLocation = 'boat'
            options = field:'output', canBeEmpty:false
            expect(-> parser._parseItemList [], options).to.throw Error, 'output for boat cannot be empty'

        it 'can allow an empty list', ->
            list = parser._parseItemList [], canBeEmpty:true
            list.length.should.equal 0

        it 'can parse a non-empty list', ->
            list = parser._parseItemList [[3, 'plank'], [3, 'wool']]
            (i.name for i in list).sort().should.eql ['plank', 'wool']

    describe '_parseItem', ->

        it 'requires the array to have at least one element', ->
            parser._errorLocation = 'boat'
            options = index:1, field:'output'
            expect(-> parser._parseItem([], options)).to.throw Error,
                "output element 1 for boat must have at least one element"

        it 'can fill in a missing number', ->
            item = parser._parseItem 'boat'
            item.name.should.equal 'boat'
            item.quantity.should.equal 1

            item2 = parser._parseItem ['boat']
            item2.name.should.equal 'boat'
            item2.quantity.should.equal 1

        it 'requires the data to start with a number', ->
            parser._errorLocation = 'boat'
            options = index:1, field:'output'
            expect(-> parser._parseItem(['2', 'book'], options)).to.throw Error,
                "output element 1 for boat must start with a number"

        it 'can parse a basic item', ->
            item = parser._parseItem [2, 'book']
            item.constructor.name.should.equal 'Item'
