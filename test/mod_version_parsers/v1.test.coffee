###
Crafting Guide - mod_version_parsers/v1.test.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

Item       = require '../../src/scripts/models/item'
ModVersion = require '../../src/scripts/models/mod_version'
V1         = require '../../src/scripts/models/mod_version_parsers/v1'

########################################################################################################################

modVersion = parser = null

########################################################################################################################

describe "ModParserVersion.V1", ->

    beforeEach ->
        parser = new V1
        modVersion = parser.modVersion = new ModVersion name:'Test', version:'0.0'

    describe '_parseModVersion', ->

        it 'requires a mod_name', ->
            data = version:'1.0', items:[]
            expect(-> parser._parseModVersion data).to.throw Error, 'name is required'

        it 'requires a mod_version', ->
            data = name:'Empty', items:[]
            expect(-> parser._parseModVersion data).to.throw Error, 'version is required'

        it 'can parse an empty modVersion', ->
            data =
                name: 'Empty'
                version: '1.0'
                recipes: []
            modVersion = parser._parseModVersion data
            modVersion.name.should.equal 'Empty'
            modVersion.version.should.equal '1.0'

        it 'can parse a non-empty mod version', ->
            data =
                name: 'Minecraft'
                version: '1.7.10'
                recipes: [
                    { input:'Sugar Cane', output:'Sugar' }
                    { input:[[3, 'Wool'], [3, 'Planks']], tools:'Crafting Table', output:'Bed' }
                ]
            modVersion = parser._parseModVersion data
            modVersion.name.should.equal 'Minecraft'
            modVersion.version.should.equal '1.7.10'
            slugs = (slug for slug, item of modVersion.items).sort()
            slugs.should.eql ['bed', 'sugar']

    describe '_parseRawMaterials', ->

        it 'skips the section when missing', ->
            parser._parseRawMaterials null
            _.keys(modVersion._items).length.should.equal 0

        it 'skips the section when empty', ->
            parser._parseRawMaterials []
            _.keys(modVersion._items).length.should.equal 0

        it 'adds items marked as gatherable', ->
            parser._parseRawMaterials ['Wool']
            modVersion.items['wool'].isGatherable.should.be.true

        it 'marks an existing item as gatherable', ->
            item = new Item modVersion:modVersion, name:'Wool'
            modVersion.items['wool'].isGatherable.should.be.false
            parser._parseRawMaterials ['Wool']
            modVersion.items['wool'].isGatherable.should.be.true

        it 'registers the names of the items', ->
            parser._parseRawMaterials ['Wool']
            modVersion.names['wool'].should.equal 'Wool'

    describe '_parseRecipe', ->

        it 'requires output to be defined', ->
            parser._errorLocation = 'boat'
            test = -> parser._parseRecipe {input:'wool'}
            expect(test).to.throw Error, 'boat is missing output'

        it 'requires input to be defined', ->
            test = -> parser._parseRecipe {output:'wool'}
            expect(test).to.throw Error, 'recipe for wool is missing input'

        it 'can parse a regular recipe', ->
            data =
                output: 'bed'
                input: [[3, 'planks'], [3, 'wool']]
                tools: 'crafting table'
            recipe = parser._parseRecipe data
            (stack.itemSlug for stack in recipe.output).should.eql ['bed']
            (stack.itemSlug for stack in recipe.input).sort().should.eql ['planks', 'wool']
            (stack.itemSlug for stack in recipe.tools).should.eql ['crafting_table']

        it 'can parse a recipe without tools', ->
            recipe = parser._parseRecipe {output:'sugar', input:'sugar cane'}
            (stack.itemSlug for stack in recipe.output).should.eql ['sugar']
            (stack.itemSlug for stack in recipe.input).sort().should.eql ['sugar_cane']
            (stack.itemSlug for stack in recipe.tools).should.eql []

        it 'registers all names', ->
            data =
                output: 'Bed'
                input: [[3, 'Oak Wood Planks'], [3, 'Wool']]
                tools: 'Crafting Table'
            parser._parseRecipe data
            _.keys(modVersion.names).sort().should.eql ['bed', 'crafting_table', 'oak_wood_planks', 'wool']

    describe '_parseStack', ->

        it 'requires the array to have at least one element', ->
            parser._errorLocation = 'boat'
            options = index:1, field:'output'
            expect(-> parser._parseStack([], options)).to.throw Error,
                "output element 1 for boat must have at least one element"

        it 'can fill in a missing number', ->
            stack = parser._parseStack 'boat'
            stack.itemSlug.should.equal 'boat'
            stack.quantity.should.equal 1

            stack2 = parser._parseStack ['boat']
            stack2.itemSlug.should.equal 'boat'
            stack2.quantity.should.equal 1

        it 'requires the data to start with a number', ->
            parser._errorLocation = 'boat'
            options = index:1, field:'output'
            expect(-> parser._parseStack(['2', 'wool'], options)).to.throw Error,
                "output element 1 for boat must start with a number"

        it 'can parse a basic item', ->
            stack = parser._parseStack [2, 'wool']
            stack.constructor.name.should.equal 'Stack'

    describe '_parseStackList', ->

        it 'can promote a single item to a list', ->
            list = parser._parseStackList 'boat'
            (stack.itemSlug for stack in list).should.eql ['boat']

        it 'can require a list to be non-empty', ->
            parser._errorLocation = 'boat'
            options = field:'output', canBeEmpty:false
            expect(-> parser._parseStackList [], options).to.throw Error, 'output for boat cannot be empty'

        it 'can allow an empty list', ->
            list = parser._parseStackList [], canBeEmpty:true
            list.length.should.equal 0

        it 'can parse a non-empty list', ->
            list = parser._parseStackList [[3, 'plank'], [3, 'wool']]
            (stack.itemSlug for stack in list).sort().should.eql ['plank', 'wool']
