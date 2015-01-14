###
Crafting Guide - mod_version_parsers/v2.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

V2 = require '../../src/scripts/models/mod_version_parsers/v2'

########################################################################################################################

baseText = parser = null

########################################################################################################################

describe 'ModVersionParser.V2', ->

    beforeEach -> parser = new V2

    describe 'Item', ->

        beforeEach -> baseText = 'name:Alpha Bravo; version:1; '

        it 'allows multiple recipes', ->
            recipes = "item: Charlie;
                recipe:; input:Alpha; pattern:... .0. ...;
                recipe:; input:Bravo; pattern:... 0.0 ...;"
            modVersion = parser.parse baseText + recipes
            recipes = modVersion.items.charlie.recipes
            recipes[0].input[0].itemSlug.should.equal 'alpha'
            recipes[1].input[0].itemSlug.should.equal 'bravo'

        describe 'name', ->

            it 'adds the name when present', ->
                modVersion = parser.parse baseText + 'item: Charlie'
                modVersion.items.charlie.name.should.equal 'Charlie'

            it 'requires a non-empty name', ->
                func = -> parser.parse baseText + 'item: \n'
                expect(func).to.throw Error, 'cannot be empty'

        describe 'gatherable', ->

            it 'adds "gatherable" when present', ->
                modVersion = parser.parse baseText + 'item: Alpha Bravo; gatherable: yes'
                modVersion.items.alpha_bravo.isGatherable.should.be.true

            it 'does not allow a duplicate "gatherable" declaration', ->
                func = -> parser.parse baseText + 'item: Alpha Bravo; gatherable: yes; gatherable: yes'
                expect(func).to.throw Error, 'duplicate'

            it 'requires "gatherable" to be "yes" or "no"', ->
                func = -> parser.parse baseText + 'item: Alpha Bravo; gatherable: true'
                expect(func).to.throw Error, 'gatherable must be'

            it 'does not allow "gatherable" before "item"', ->
                func = -> parser.parse baseText + 'gatherable: yes; item: Alpha Bravo; gatherable: yes'
                expect(func).to.throw Error, '"gatherable" before "item"'

    describe 'ModVersion', ->

        it 'allows declarations in any order', ->
            modVersion = parser.parse 'item: Alpha; version:1; name:Bravo Charlie'
            modVersion.name.should.equal 'Bravo Charlie'
            modVersion.version.should.equal '1'
            modVersion.items.alpha.name.should.equal 'Alpha'

        it 'does not allow duplicate item declarations', ->
            func = -> parser.parse 'version:1; name:Alpha Bravo; item:Charlie; item:Charlie'
            expect(func).to.throw Error, 'duplicate item for Charlie'

        it 'allows multiple items', ->
            modVersion = parser.parse 'name:Alpha; version:1; item:Bravo; item:Charlie'
            _.keys(modVersion.items).sort().should.eql ['bravo', 'charlie']

        describe 'name', ->

            it 'adds "name" when present', ->
                modVersion = parser.parse 'name:Alpha Bravo; version:1'
                modVersion.name.should.equal 'Alpha Bravo'

            it 'does not allow a duplicate "name" declaration', ->
                func = -> parser.parse 'name:Alpha Bravo; version:1; name:Charlie'
                expect(func).to.throw Error, 'duplicate declaration of "name"'

            it 'requires a "name" declaration', ->
                func = -> parser.parse 'version:1; item:Alpha'
                expect(func).to.throw Error, 'the "name" declaration is required'

        describe 'version', ->

            it 'adds "version" when present', ->
                modVersion = parser.parse 'name:Alpha Bravo; version:1'
                modVersion.version.should.equal '1'

            it 'does not allow a duplicate "version" declaration', ->
                func = -> parser.parse 'name:Alpha Bravo; version:1; item:Charlie; version:2'
                expect(func).to.throw Error, 'duplicate declaration of "version"'

            it 'requires a "version" declaration', ->
                func = -> parser.parse 'name:Alpha Bravo; item:Charlie'
                expect(func).to.throw Error, 'the "version" declaration is required'

        describe 'description', ->

            it 'adds "description" when present', ->
                modVersion = parser.parse 'name:Alpha; version:1; description:Charlie Delta'
                modVersion.description.should.equal 'Charlie Delta'

            it 'does not allow a duplicate "description" declaration', ->
                func = -> parser.parse 'name:Alpha; version:1; description:Bravo; description:Charlie'
                expect(func).to.throw Error, 'duplicate declaration of "description"'

    describe 'Recipe', ->

        beforeEach -> baseText = 'name:Alpha Bravo; version:1; item: Charlie; '

        describe 'input', ->

            it 'adds "input" when present', ->
                modVersion = parser.parse baseText + 'recipe:; input:Alpha, Bravo, Charlie; pattern: ... 012 ...'
                slugs = (s.itemSlug for s in modVersion.items.charlie.recipes[0].input)
                slugs.should.eql ['alpha', 'bravo', 'charlie']

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
                _.keys(modVersion.names).sort().should.eql ['charlie', 'delta', 'echo', 'foxtrot']

        describe 'pattern', ->

            it 'adds "pattern" when present', ->
                modVersion = parser.parse baseText + 'recipe:; input:Alpha, Bravo; pattern:... .0. .1.'
                modVersion.items.charlie.recipes[0].pattern.should.equal '... .0. .1.'

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
                expect(func).to.throw Error, 'there is no input 1 in this recipe'

            it 'requires all items to appear in the pattern', ->
                func = -> parser.parse baseText + 'recipe:; input:Alpha, Bravo; pattern: 000 0.0 000'
                expect(func).to.throw Error, 'Bravo is an input'

            it 'computes the input stack sizes from the pattern', ->
                modVersion = parser.parse baseText + 'recipe:; input:Alpha, Bravo, Charlie; pattern:111 .0. 2.2'
                recipe = modVersion.items.charlie.recipes[0]
                recipe.input[0].quantity.should.equal 1
                recipe.input[1].quantity.should.equal 3
                recipe.input[2].quantity.should.equal 2

            it 'does not allow "pattern" before "recipe"', ->
                func = -> parser.parse baseText + 'pattern:... .0. ...; recipe:; inputs:Alpha'
                expect(func).to.throw Error, 'cannot declare "pattern" before "recipe"'

        describe 'quantity', ->

            beforeEach ->
                baseText = 'name:Alpha Bravo; version:1; item: Charlie; recipe:; input:Alpha; pattern:...0.0...; '

            it 'adds "quantity" when present', ->
                modVersion = parser.parse baseText + 'quantity: 2'
                modVersion.items.charlie.recipes[0].output[0].quantity.should.equal 2

            it 'does not allow a duplicate "quantity" declaration', ->
                func = -> parser.parse baseText + 'quantity:1; quantity:2'
                expect(func).to.throw Error, 'duplicate declaration of "quantity"'

            it 'requires quantity to be an integer', ->
                func = -> parser.parse baseText + 'quantity:ten'
                expect(func).to.throw Error, 'quantity must be an integer'

            it 'assumes a quantity of 1 by default', ->
                modVersion = parser.parse baseText
                modVersion.items.charlie.recipes[0].output[0].quantity.should.equal 1

            it 'does not allow "quantity" before recipe', ->
                func = -> parser.parse 'name:Alpha; version:1; item:Bravo; quantity:12; recipe:;'
                expect(func).to.throw Error, 'cannot declare "quantity" before "recipe"'

        describe 'output', ->

            beforeEach ->
                baseText = 'name:Alpha; version:1; item:Bravo; recipe:; input:Charlie; pattern:... .0. ...; '

            it 'adds a single item as the default output', ->
                modVersion = parser.parse baseText
                stack = modVersion.items.bravo.recipes[0].output[0]
                stack.itemSlug.should.equal 'bravo'
                stack.quantity.should.equal 1

            it 'can add multiple extras with quantities', ->
                modVersion = parser.parse baseText + 'extras:2 Delta, 4 Echo'
                output = modVersion.items.bravo.recipes[0].output
                output[0].itemSlug.should.equal 'bravo'
                output[0].quantity.should.equal 1
                output[1].itemSlug.should.equal 'delta'
                output[1].quantity.should.equal 2
                output[2].itemSlug.should.equal 'echo'
                output[2].quantity.should.equal 4

            it 'does not allow "extras" before "recipe"', ->
                func = -> parser.parse 'name:Alpha; version:1; item:Bravo; extras:Charlie'
                expect(func).to.throw Error, 'cannot declare "extras" before "recipe"'

            it 'registers slugs for each output name', ->
                modVersion = parser.parse baseText + 'extras:Delta, Echo'
                _.keys(modVersion.names).sort().should.eql ['bravo', 'charlie', 'delta', 'echo']

            it 'does not allow a duplicate "extras" declaration', ->
                func = -> parser.parse baseText + 'extras:Echo; extras:Delta'
                expect(func).to.throw Error, 'duplicate declaration of "extras"'

        describe 'tools', ->

            beforeEach ->
                baseText = 'name:Alpha; version:1; item:Bravo; recipe:; input:Charlie; pattern:... .0. ...; '

            it 'can add a single tool', ->
                modVersion = parser.parse baseText + 'tools: Furnace'
                modVersion.items.bravo.recipes[0].tools[0].itemSlug.should.equal 'furnace'

            it 'can add multiple tools', ->
                modVersion = parser.parse baseText + 'tools: Crafting Table, Furnace'
                tools = modVersion.items.bravo.recipes[0].tools
                tools[0].itemSlug.should.equal 'crafting_table'
                tools[1].itemSlug.should.equal 'furnace'

            it 'registers slugs for each tool name', ->
                modVersion = parser.parse baseText + 'tools: Crafting Table, Furnace'
                _.keys(modVersion.names).sort().should.eql ['bravo', 'charlie', 'crafting_table', 'furnace']

            it 'does not allow a duplicate "tools" declaration', ->
                func = -> parser.parse baseText + 'tools:Crafting Table; tools:Furnace'
                expect(func).to.throw Error, 'duplicate declaration of "tools"'
