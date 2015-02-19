###
Crafting Guide - recipe.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Item     = require '../src/scripts/models/item'
ItemSlug = require '../src/scripts/models/item_slug'
Recipe   = require '../src/scripts/models/recipe'
Stack    = require '../src/scripts/models/stack'

########################################################################################################################

input = output = pattern = recipe = null

########################################################################################################################

describe 'recipe.coffee', ->

    describe 'constructor', ->

        beforeEach ->
            input = [
                new Stack(itemSlug:new ItemSlug('iron_gear')),
                new Stack(itemSlug:new ItemSlug('gold_ingot'), quantity:4)
            ]
            pattern = '.1. 101 .1.'

        it 'requires input', ->
            expect(-> new Recipe slug:'gold_gear', pattern:pattern).to.throw Error, 'attributes.input is required'

        it 'requires a pattern', ->
            expect(-> new Recipe slug:'gold_gear', input:input).to.throw Error, 'attributes.pattern is required'

        it 'requires either outputs or a slug', ->
            f = -> new Recipe input:input, pattern:pattern
            expect(f).to.throw 'attributes.itemSlug or attributes.output is required'

        it 'creates default output', ->
            recipe = new Recipe itemSlug:ItemSlug.slugify('gold_gear'), input:input, pattern:pattern
            recipe.output.length.should.equal 1
            recipe.output[0].itemSlug.qualified.should.equal 'gold_gear'
            recipe.output[0].quantity.should.equal 1

        it 'assigns a default slug', ->
            recipe = new Recipe input:input, pattern:pattern, output:[new Stack itemSlug:ItemSlug.slugify('gold_gear')]
            recipe.itemSlug.qualified.should.equal 'gold_gear'

    describe 'getItemSlugAt', ->

        beforeEach ->
            input = [
                new Stack itemSlug:ItemSlug.slugify('iron_gear')
                new Stack itemSlug:ItemSlug.slugify('gold_ingot'), quantity:4
            ]
            recipe = new Recipe itemSlug:'gold_gear', input:input, pattern:'.1. 101 .1.'

        it 'returns the proper item for an early slot', ->
            recipe.getItemSlugAt(1).qualified.should.equal 'gold_ingot'

        it 'returns the proper item for a late slot', ->
            recipe.getItemSlugAt(4).qualified.should.equal 'iron_gear'

        it 'returns null for an invalid slot', ->
            expect(recipe.getItemSlugAt(12)).to.be.null

    describe '_parsePattern', ->

        beforeEach ->
            recipe = new Recipe
                itemSlug:  'oak_wood_planks',
                input: [new Stack itemSlug:new ItemSlug('oak_wood')],
                pattern:'... .0. ...'

        it 'normalizes invalid characters', ->
            recipe._parsePattern('$$0 #() 010').should.equal '..0 ... 010'

        it 'removes extra characters', ->
            recipe._parsePattern('000 000 000 000').should.equal '000 000 000'

        it 'fills in missing characters', ->
            recipe._parsePattern('000000').should.equal '000 000 ...'

        it 'fills in spaces', ->
            recipe._parsePattern('000000000').should.equal '000 000 000'
