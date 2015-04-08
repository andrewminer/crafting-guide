###
Crafting Guide - mod_version_parser_v1.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

CommandParserVersionBase = require '../../src/coffee/models/parser_versions/command_parser_version_base'
ItemSlug                 = require '../../src/coffee/models/item_slug'
ModVersion               = require '../../src/coffee/models/mod_version'
ModVersionParserV1       = require '../../src/coffee/models/parser_versions/mod_version_parser_v1'
{Logger}                 = require 'crafting-guide-common'

########################################################################################################################

baseText = modVersion = parser = null

########################################################################################################################

describe 'mod_version_parser_v1.coffee', ->

    beforeEach ->
        modVersion = new ModVersion modSlug:'test', version:'0.0'
        parser     = new ModVersionParserV1 model:modVersion

    describe 'Item', ->

        it 'allows multiple recipes', ->
            recipes = "item: Charlie;
                recipe:; input:Alpha; pattern:... .0. ...;
                recipe:; input:Bravo; pattern:... 0.0 ...;"
            modVersion = parser.parse recipes
            recipes = modVersion.findRecipes ItemSlug.slugify 'test__charlie'
            recipes[0].input[0].itemSlug.qualified.should.equal 'alpha'
            recipes[1].input[0].itemSlug.qualified.should.equal 'bravo'

        describe 'name', ->

            it 'adds the name when present', ->
                modVersion = parser.parse 'item: Charlie'
                modVersion._items.charlie.name.should.equal 'Charlie'

            it 'requires a non-empty name', ->
                func = -> parser.parse 'item: \n'
                expect(func).to.throw Error, 'cannot be empty'

        describe 'gatherable', ->

            it 'adds "gatherable" when present', ->
                modVersion = parser.parse 'item: Alpha Bravo; gatherable: yes'
                modVersion._items.alpha_bravo.isGatherable.should.be.true

            it 'does not allow a duplicate "gatherable" declaration', ->
                func = -> parser.parse 'item: Alpha Bravo; gatherable: yes; gatherable: yes'
                expect(func).to.throw Error, 'duplicate'

            it 'requires "gatherable" to be "yes" or "no"', ->
                func = -> parser.parse 'item: Alpha Bravo; gatherable: true'
                expect(func).to.throw Error, 'gatherable must be'

            it 'does not allow "gatherable" before "item"', ->
                func = -> parser.parse 'gatherable: yes; item: Alpha Bravo; gatherable: yes'
                expect(func).to.throw Error, '"gatherable" before "item"'

    describe 'Recipe', ->

        beforeEach -> baseText = 'item: Charlie; '

        describe 'input', ->

            it 'adds "input" when present', ->
                modVersion = parser.parse baseText + 'recipe:; input:Alpha, Bravo; pattern: ... 010 ...'
                charlieSlug = ItemSlug.slugify('test__charlie')
                slugs = (s.itemSlug.item for s in modVersion.findRecipes(charlieSlug)[0].input)
                slugs.should.eql ['alpha', 'bravo']

            it 'requires an "input" declaration', ->
                func = -> parser.parse baseText + 'recipe:; pattern: ... .0. ...'
                expect(func).to.throw Error, 'the "input" declaration is required'

            it 'does not allow a duplicate "input" declaration', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha; pattern:....0....; input:Bravo'
                expect(func).to.throw Error, 'duplicate declaration of "input"'

            it 'does not allow "input" before "recipe"', ->
                func = -> parser.parse baseText + 'input:Alpha, Bravo; recipe:; pattern:....0....'
                expect(func).to.throw Error, 'cannot declare "input" before "recipe"'

            it 'registers slugs for each input name', ->
                modVersion = parser.parse baseText + 'recipe:; input:Delta, Echo, Foxtrot; pattern:...012...'
                (s.item for s in modVersion._slugs).should.eql ['charlie', 'delta', 'echo', 'foxtrot']

            it 'allows a quantity for each input', ->
                modVersion = parser.parse baseText + 'recipe:; input: 12 Delta, 3 Echo; pattern:... 0.1 ...'
                recipe = _.values(modVersion._recipes)[0]
                recipe.input[0].quantity.should.equal 12
                recipe.input[0].itemSlug.qualified.should.equal 'delta'
                recipe.input[1].quantity.should.equal 3
                recipe.input[1].itemSlug.qualified.should.equal 'echo'

        describe 'pattern', ->

            it 'adds "pattern" when present', ->
                modVersion = parser.parse baseText + 'recipe:; input:Alpha, Bravo; pattern:... .0. .1.'
                modVersion.findRecipes(ItemSlug.slugify('test__charlie'))[0].pattern.should.equal '... .0. .1.'

            it 'requires a "pattern" declaration', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha, Bravo'
                expect(func).to.throw Error, 'the "pattern" declaration is required'

            it 'does not allow a duplicate "pattern" declaration', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha, Bravo; pattern:....0..1.; pattern:01.......'
                expect(func).to.throw Error, 'duplicate declaration of "pattern"'

            it 'requires pattern to be the right length', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha; pattern:000'
                expect(func).to.throw Error, 'a pattern must have'

            it 'requires pattern to only use proper characters', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha; pattern:abc def ghi'
                expect(func).to.throw Error, 'a pattern must have'

            it 'requires pattern to only refer to existing items', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha; pattern:... 010 ...'
                expect(func).to.throw Error, 'there is no item 1 in this recipe'

            it 'requires all items to appear in the pattern', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha, Bravo; pattern: 000 0.0 000'
                expect(func).to.throw Error, 'Bravo is listed'

            it 'does not allow "pattern" before "recipe"', ->
                func = -> parser.parse baseText + 'pattern:... .0. ...; recipe:; inputs:Alpha'
                expect(func).to.throw Error, 'cannot declare "pattern" before "recipe"'

        describe 'quantity', ->

            beforeEach ->
                baseText = 'item: Charlie; recipe:; input:Alpha; pattern:...0.0...; '

            it 'adds "quantity" when present', ->
                modVersion = parser.parse baseText + 'quantity: 2'
                modVersion.findRecipes(ItemSlug.slugify('test__charlie'))[0].output[0].quantity.should.equal 2

            it 'does not allow a duplicate "quantity" declaration', ->
                func = -> parser.parse baseText + 'quantity:1; quantity:2'
                expect(func).to.throw Error, 'duplicate declaration of "quantity"'

            it 'requires quantity to be an integer', ->
                func = -> parser.parse baseText + 'quantity:ten'
                expect(func).to.throw Error, 'quantity must be an integer'

            it 'assumes a quantity of 1 by default', ->
                modVersion = parser.parse baseText
                modVersion.findRecipes(ItemSlug.slugify('test__charlie'))[0].output[0].quantity.should.equal 1

            it 'does not allow "quantity" before recipe', ->
                func = -> parser.parse 'item:Bravo; quantity:12; recipe:;'
                expect(func).to.throw Error, 'cannot declare "quantity" before "recipe"'

        describe 'output', ->

            beforeEach ->
                baseText = 'item: Delta; item:Bravo; recipe:; input:Charlie; pattern:... .0. ...; '

            it 'adds a single item as the default output', ->
                modVersion = parser.parse baseText
                stack = modVersion.findRecipes(ItemSlug.slugify('test__bravo'))[0].output[0]
                stack.itemSlug.qualified.should.equal 'test__bravo'
                stack.quantity.should.equal 1

            it 'can add multiple extras with quantities', ->
                modVersion = parser.parse baseText + 'extras:2 Delta, 4 Echo'
                output = modVersion.findRecipes(ItemSlug.slugify('test__bravo'))[0].output
                output[0].itemSlug.qualified.should.equal 'test__bravo'
                output[0].quantity.should.equal 1
                output[1].itemSlug.qualified.should.equal 'test__delta'
                output[1].quantity.should.equal 2
                output[2].itemSlug.qualified.should.equal 'echo'
                output[2].quantity.should.equal 4

            it 'does not allow "extras" before "recipe"', ->
                func = -> parser.parse 'item:Bravo; extras:Charlie'
                expect(func).to.throw Error, 'cannot declare "extras" before "recipe"'

            it 'registers slugs for each output name', ->
                modVersion = parser.parse baseText + 'extras:Delta, Echo'
                (s.qualified for s in modVersion._slugs).should.eql [
                    'test__bravo', 'charlie', 'test__delta', 'echo'
                ]

            it 'does not allow a duplicate "extras" declaration', ->
                func = -> parser.parse baseText + 'extras:Echo; extras:Delta'
                expect(func).to.throw Error, 'duplicate declaration of "extras"'

        describe 'tools', ->

            beforeEach ->
                baseText = 'item:Bravo; recipe:; input:Charlie; pattern:... .0. ...; '

            it 'can add a single tool', ->
                modVersion = parser.parse baseText + 'tools: Furnace'
                modVersion.findRecipes(ItemSlug.slugify('test__bravo'))[0].tools[0].itemSlug.item.should.equal 'furnace'

            it 'can add multiple tools', ->
                modVersion = parser.parse baseText + 'tools: Crafting Table, Furnace'
                tools = modVersion.findRecipes(ItemSlug.slugify('test__bravo'))[0].tools
                tools[0].itemSlug.item.should.equal 'crafting_table'
                tools[1].itemSlug.item.should.equal 'furnace'

            it 'registers slugs for each tool name', ->
                modVersion = parser.parse baseText + 'tools: Crafting Table, Furnace'
                (s.item for s in modVersion._slugs).should.eql ['bravo', 'charlie', 'crafting_table', 'furnace']

            it 'does not allow a duplicate "tools" declaration', ->
                func = -> parser.parse baseText + 'tools:Crafting Table; tools:Furnace'
                expect(func).to.throw Error, 'duplicate declaration of "tools"'

    describe "unparsing", ->

        beforeEach ->
            baseText = """
                schema: 1

                group: Agriculture

                    item: Apple

                    item: Baked Potato
                        recipe:
                            input: furnace fuel, Potato
                            pattern: .1. ... .0.
                            tools: Furnace

                    item: (filled) Canned Food
                        recipe:
                            input: 4 (Empty) Tin Can, Apple
                            pattern: .1. .0. ...

                group: Functional Blocks

                    item: Furnace
                        recipe:
                            input: Cobblestone
                            pattern: 000 0.0 000
                            tools: Crafting Table

                update: Iron Ingot
                    recipe:
                        input: furnace fuel, Iron Dust
                        pattern: .1. ... .0.
                        tools: Furnace
            """

        it 'can round-trip a data file', ->
            text     = parser.unparse parser.parse baseText
            actual   = CommandParserVersionBase.simplify text
            expected = CommandParserVersionBase.simplify baseText

            actual.should.equal expected
