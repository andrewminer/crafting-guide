###
Crafting Guide - v1.test.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

Item             = require '../src/scripts/models/item'
ModVersion       = require '../src/scripts/models/mod_version'
ModVersionParser = require '../src/scripts/models/mod_version_parser'

########################################################################################################################

parser = null

########################################################################################################################

describe 'ModVersionParser', ->

    describe "V1", ->

        before -> parser = new ModVersionParser.V1

        describe '_parseItemList', ->

            beforeEach -> parser.modVersion = new ModVersion modName:'Test', modVersion:'0.0'

            it 'can parse an empty list', ->
                parser._parseItemList []
                _.keys(parser.modVersion.items).should.eql []

            it 'can add new items', ->
                parser._parseItemList ['Crafting Table', 'Furnace']
                _.keys(parser.modVersion.items).should.eql ['crafting_table', 'furnace']

            it 'can find existing items', ->
                parser.modVersion.addItem new Item name:'Furnace'
                parser._parseItemList ['Crafting Table', 'Furnace']
                _.keys(parser.modVersion.items).should.eql ['furnace', 'crafting_table']

        describe '_parseModVersion', ->

            it 'requires a mod_name', ->
                data = version:1, mod_version:'1.0', items:[]
                expect(-> parser._parseModVersion data).to.throw Error, 'mod_name is required'

            it 'requires a mod_version', ->
                data = version:1, mod_name:'Empty', items:[]
                expect(-> parser._parseModVersion data).to.throw Error, 'mod_version is required'

            it 'can parse an empty modVersion', ->
                data =
                    version: 1
                    mod_name: 'Empty'
                    mod_version: '1.0'
                    recipes: []
                modVersion = parser._parseModVersion data
                modVersion.modName.should.equal 'Empty'
                modVersion.modVersion.should.equal '1.0'

            it 'can parse a non-empty mod version', ->
                data =
                    version: 1
                    mod_name: 'Minecraft'
                    mod_version: '1.7.10'
                    recipes: [
                        { input:'Sugar Cane', output:'Sugar' }
                        { input:[[3, 'Wool'], [3, 'Planks']], tools:'Crafting Table', output:'Bed' }
                    ]
                modVersion = parser._parseModVersion data
                modVersion.modName.should.equal 'Minecraft'
                modVersion.modVersion.should.equal '1.7.10'
                slugs = (slug for slug, item of modVersion.items).sort()
                slugs.should.eql ['bed', 'crafting_table', 'planks', 'sugar', 'sugar_cane', 'wool']

        describe '_parseRawMaterials', ->

            beforeEach -> parser.modVersion = new ModVersion modName:'Test', modVersion:'0.0'

            it 'skips the section when missing', ->
                parser._parseRawMaterials null
                _.keys(parser.modVersion._items).length.should.equal 0

            it 'skips the section when empty', ->
                parser._parseRawMaterials []
                _.keys(parser.modVersion._items).length.should.equal 0

            it 'adds items marked as gatherable', ->
                parser._parseRawMaterials ['Wool']
                parser.modVersion.items['wool'].isGatherable.should.be.true

            it 'marks an existing item as gatherable', ->
                parser.modVersion.addItem new Item name:'Wool'
                parser.modVersion.items['wool'].isGatherable.should.be.false
                parser._parseRawMaterials ['Wool']
                parser.modVersion.items['wool'].isGatherable.should.be.true


        describe '_parseRecipe', ->

            beforeEach -> parser.modVersion = new ModVersion modName:'Test', modVersion:'0.0'

            it 'requires output to be defined', ->
                parser._errorLocation = 'boat'
                expect(-> parser._parseRecipe input:'wool').to.throw Error, 'boat is missing output'

            it 'requires input to be defined', ->
                expect(-> parser._parseRecipe output:'wool').to.throw Error, 'recipe for wool is missing input'

            it 'can parse a regular recipe', ->
                data =
                    output: 'bed'
                    input: [[3, 'planks'], [3, 'wool']]
                    tools: 'crafting table'
                recipe = parser._parseRecipe data
                (stack.name for stack in recipe.output).should.eql ['bed']
                (stack.name for stack in recipe.input).sort().should.eql ['planks', 'wool']
                (item.name for item in recipe.tools).should.eql ['crafting table']

            it 'can parse a recipe without tools', ->
                recipe = parser._parseRecipe output:'sugar', input:'sugar cane'
                (stack.name for stack in recipe.output).should.eql ['sugar']
                (stack.name for stack in recipe.input).sort().should.eql ['sugar cane']
                (stack.name for stack in recipe.tools).should.eql []

        describe '_parseStack', ->

            beforeEach -> parser.modVersion = new ModVersion modName:'Test', modVersion:'0.0'

            it 'requires the array to have at least one element', ->
                parser._errorLocation = 'boat'
                options = index:1, field:'output'
                expect(-> parser._parseStack([], options)).to.throw Error,
                    "output element 1 for boat must have at least one element"

            it 'can fill in a missing number', ->
                item = parser._parseStack 'boat'
                item.name.should.equal 'boat'
                item.quantity.should.equal 1

                item2 = parser._parseStack ['boat']
                item2.name.should.equal 'boat'
                item2.quantity.should.equal 1

            it 'requires the data to start with a number', ->
                parser._errorLocation = 'boat'
                options = index:1, field:'output'
                expect(-> parser._parseStack(['2', 'wool'], options)).to.throw Error,
                    "output element 1 for boat must start with a number"

            it 'can parse a basic item', ->
                stack = parser._parseStack [2, 'wool']
                stack.constructor.name.should.equal 'Stack'

        describe '_parseStackList', ->

            beforeEach -> parser.modVersion = new ModVersion modName:'Test', modVersion:'0.0'

            it 'can promote a single item to a list', ->
                list = parser._parseStackList 'boat'
                (i.name for i in list).should.eql ['boat']

            it 'can require a list to be non-empty', ->
                parser._errorLocation = 'boat'
                options = field:'output', canBeEmpty:false
                expect(-> parser._parseStackList [], options).to.throw Error, 'output for boat cannot be empty'

            it 'can allow an empty list', ->
                list = parser._parseStackList [], canBeEmpty:true
                list.length.should.equal 0

            it 'can parse a non-empty list', ->
                list = parser._parseStackList [[3, 'plank'], [3, 'wool']]
                (i.name for i in list).sort().should.eql ['plank', 'wool']
