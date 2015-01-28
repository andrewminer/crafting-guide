###
Crafting Guide - mod_version.test.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

Item       = require '../src/scripts/models/item'
ModVersion = require '../src/scripts/models/mod_version'

########################################################################################################################

modVersion = null

########################################################################################################################

describe 'mod_version.coffee', ->

    beforeEach -> modVersion = new ModVersion modSlug:'test', version:'0.0'

    describe 'constructor', ->

        it 'requires a mod slug', ->
            expect(-> new ModVersion version:'0.0').to.throw Error, 'attributes.modSlug is required'

        it 'requires a mod version', ->
            expect(-> new ModVersion modSlug:'test').to.throw Error, 'attributes.version is required'

    describe 'addItem', ->

        it 'refuses to add duplicates', ->
            modVersion.addItem new Item name:'Wool'
            expect(-> modVersion.addItem new Item name:'Wool').to.throw Error, 'duplicate item for Wool'

        it 'adds an item indexed by its slug', ->
            modVersion.addItem new Item name:'Wool'
            modVersion._items.wool.name.should.equal 'Wool'

        it 'sets the modVersion', ->
            modVersion.addItem new Item name:'Wool'
            modVersion._items.wool.modVersion.should.equal modVersion

    describe 'findItemByName', ->

        it 'locates items by slugified name', ->
            modVersion.addItem new Item name:'Crafting Table'
            modVersion.findItemByName('Crafting Table').slug.should.equal 'crafting_table'

    describe 'findRecipes', ->

        beforeEach ->
            modVersion = new ModVersion modSlug:'test', version:'1.0'
            modVersion.parse """
                schema:1

                item: Cake
                    recipe:; input: Milk, Sugar, Egg, Wheat; pattern: 000 121 333; extras: 3 Bucket
                    recipe:; input: Milk, Cocoa Beans, Egg, Wheat; pattern: 000 121 333; extras: 3 Bucket
                item: Bucket
                    recipe:; input: Iron Ingot; pattern: ... 0.0 .0.
            """

        it 'finds all recipes which list item as output', ->
            recipes = modVersion.findRecipes 'bucket'
            (r.output[0].slug for r in recipes).sort().should.eql ['bucket', 'cake', 'cake']
