###
Crafting Guide - recipe.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Item   = require '../src/scripts/models/item'
Recipe = require '../src/scripts/models/recipe'
Stack  = require '../src/scripts/models/stack'

########################################################################################################################

input = output = pattern = recipe = null

########################################################################################################################

describe 'recipe.coffee', ->

    describe 'constructor', ->

        beforeEach ->
            input = [ new Stack(slug:'iron_gear'), new Stack(slug:'gold_ingot', quantity:4) ]
            pattern = '.1. 101 .1.'

        it 'requires a name', ->
            expect(-> new Recipe input:input, pattern:pattern).to.throw Error, 'attributes.name is required'

        it 'requires input', ->
            expect(-> new Recipe name:'Gold Gear', pattern:pattern).to.throw Error, 'attributes.input is required'

        it 'requires a pattern', ->
            expect(-> new Recipe name:'Gold Gear', input:input).to.throw Error, 'attributes.pattern is required'

        it 'allows an item to provide required attributes', ->
            item = new Item name:'Gold Gear'
            recipe = new Recipe item:item, input:input, pattern:pattern
            recipe.name.should.equal 'Gold Gear'
            (o.slug for o in recipe.output).should.eql ['gold_gear']

        it 'creates default output', ->
            recipe = new Recipe name:'Gold Gear', input:input, pattern:pattern
            recipe.output.length.should.equal 1
            recipe.output[0].slug.should.equal 'gold_gear'
            recipe.output[0].quantity.should.equal 1

        it 'assigns a default slug', ->
            recipe = new Recipe name:'Gold Gear', input:input, pattern:pattern
            recipe.slug.should.equal 'gold_gear'

    describe 'getItemSlugAt', ->

        beforeEach ->
            input = [ new Stack(slug:'iron_gear'), new Stack(slug:'gold_ingot', quantity:4) ]
            recipe = new Recipe name:'Gold Gear', input:input, pattern:'.1. 101 .1.'

        it 'returns the proper item for an early slot', ->
            recipe.getItemSlugAt(1).should.equal 'gold_ingot'

        it 'returns the proper item for a late slot', ->
            recipe.getItemSlugAt(4).should.equal 'iron_gear'

        it 'returns null for an invalid slot', ->
            expect(recipe.getItemSlugAt(12)).to.be.null

    describe 'doesProduce', ->

        beforeEach ->
            input = [ new Stack(slug:'empty_cell'), new Stack(slug:'water_bucket') ]
            output = [ new Stack(slug:'water_cell'), new Stack(slug:'bucket') ]
            recipe = new Recipe name:'Water Cell', input:input, output:output, pattern:'... .0. .1.'

        it 'returns true when asked for the primary output', ->
            recipe.doesProduce('water_cell').should.be.true

        it 'returns true when asked for a secondary output', ->
            recipe.doesProduce('bucket').should.be.true

        it 'return false when asked for a non-output', ->
            recipe.doesProduce('cake').should.be.false

    describe '_parsePattern', ->

        beforeEach ->
            recipe = new Recipe name:'Oak Wood Planks', input:[new Stack slug:'oak_wood'], pattern:'... .0. ...'

        it 'normalizes invalid characters', ->
            recipe._parsePattern('$$0 #() 010').should.equal '..0 ... 010'

        it 'removes extra characters', ->
            recipe._parsePattern('000 000 000 000').should.equal '000 000 000'

        it 'fills in missing characters', ->
            recipe._parsePattern('000000').should.equal '000 000 ...'

        it 'fills in spaces', ->
            recipe._parsePattern('000000000').should.equal '000 000 000'
