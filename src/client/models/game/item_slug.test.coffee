#
# Crafting Guide - item_slug.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ItemSlug = require './item_slug'

########################################################################################################################

describe 'item_slug.coffee', ->

    describe 'constructor', ->

        it 'can handle one argument', ->
            slug = new ItemSlug 'alpha'
            slug.item.should.equal 'alpha'
            expect(slug.mod).to.be.null
            slug.qualified.should.equal 'alpha'

        it 'can handle two arguments', ->
            slug = new ItemSlug 'alpha', 'bravo'
            slug.mod.should.equal 'alpha'
            slug.item.should.equal 'bravo'
            slug.qualified.should.equal 'alpha__bravo'

        it 'throws with zero arguments', ->
            f = -> new ItemSlug
            expect(f).to.throw Error, 'expected arguments to be "modSlug, itemSlug" or just "itemSlug"'

        it 'throws with more arguments', ->
            f = -> new ItemSlug 'alpha', 'bravo', 'charlie'
            expect(f).to.throw Error, 'expected arguments to be "modSlug, itemSlug" or just "itemSlug"'

    describe 'ItemSlug.compare', ->

        it 'sorts by item when both are qualified in the same mod', ->
            a = new ItemSlug 'alpha', 'bravo'
            b = new ItemSlug 'charlie', 'bravo'

            ItemSlug.compare(a, b).should.equal -1
            ItemSlug.compare(b, a).should.equal +1

        it 'sorts by item when not qualified', ->
            a = new ItemSlug 'alpha'
            b = new ItemSlug 'bravo'

            ItemSlug.compare(a, b).should.equal -1
            ItemSlug.compare(b, a).should.equal +1

    describe 'ItemSlug.equal', ->

        it 'requires both to have the same mod', ->
            a = new ItemSlug 'alpha', 'bravo'
            b = new ItemSlug 'alpha', 'charlie'
            c = new ItemSlug 'alpha', 'bravo'

            ItemSlug.equal(a, b).should.be.false
            ItemSlug.equal(a, c).should.be.true

        it 'requires both to have the same item', ->
            a = new ItemSlug 'alpha', 'bravo'
            b = new ItemSlug 'alpha', 'charlie'
            c = new ItemSlug 'alpha', 'bravo'

            ItemSlug.equal(a, b).should.be.false
            ItemSlug.equal(a, c).should.be.true

    describe 'ItemSlug.slugify', ->

        it 'can slugify a pure name', ->
            slug = ItemSlug.slugify 'Alpha Bravo (Charlie)'
            slug.item.should.equal 'alpha_bravo_charlie'
            expect(slug.mod).to.be.null

        it 'can slugify a simple item slug', ->
            slug = ItemSlug.slugify 'alpha_bravo_charlie'
            slug.item.should.equal 'alpha_bravo_charlie'
            expect(slug.mod).to.be.null

        it 'can slugify a fully-qualified slug', ->
            slug = ItemSlug.slugify 'alpha_bravo__charlie_delta'
            slug.mod.should.equal 'alpha_bravo'
            slug.item.should.equal 'charlie_delta'

    describe 'matches', ->

        it 'ignores mod when either is unqualified', ->
            a = new ItemSlug 'alpha', 'bravo'
            b = new ItemSlug 'bravo'
            c = new ItemSlug 'charlie'

            a.matches(b).should.be.true
            a.matches(c).should.be.false

        it 'observes differences in mod when all are qualified', ->
            a = new ItemSlug 'alpha', 'bravo'
            b = new ItemSlug 'charlie', 'bravo'
            c = new ItemSlug 'delta', 'echo'
            d = new ItemSlug 'alpha', 'bravo'

            a.matches(b).should.be.false
            a.matches(c).should.be.false
            a.matches(d).should.be.true

    describe 'isQualified', ->

        it 'returns true only when the mod slug is set', ->
            a = new ItemSlug 'alpha', 'bravo'
            b = new ItemSlug 'charlie'
            a.isQualified.should.be.true
            b.isQualified.should.be.false

    describe '[]', ->

        it 'allows slugs as a key', ->
            slug = new ItemSlug 'alpha', 'bravo'
            data = {}
            data[slug] = 'foo'
            data['alpha__bravo'].should.equal 'foo'
            data[slug].should.equal 'foo'
