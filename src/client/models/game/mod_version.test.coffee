#
# Crafting Guide - mod_version.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Item       = require './item'
ItemSlug   = require './item_slug'
ModVersion = require './mod_version'

########################################################################################################################

modVersion = null

########################################################################################################################

describe 'mod_version.coffee', ->

    beforeEach ->
        modVersion = new ModVersion modSlug:'test', version:'0.0'
        modVersion.addItem new Item name:'underscore', group:'punctuation'
        modVersion.addItem new Item name:'bravo',      group:'letter'
        modVersion.addItem new Item name:'alpha',      group:'letter'
        modVersion.addItem new Item name:'one',        group:'number'
        modVersion.addItem new Item name:'two',        group:'number'

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

    describe 'eachGroup', ->

        it 'returns all the groups in order', ->
            groupNames = []
            modVersion.eachGroup (groupName)-> groupNames.push groupName
            groupNames.should.eql ['letter', 'number', 'punctuation']

    describe 'eachItemInGroup', ->

        it 'returns immediately for unknown group', ->
            slugs = []
            modVersion.eachItemInGroup 'foobar', (item)-> slugs.push item.slug.qualified
            slugs.should.eql []

        it 'calls callback for exactly the items in a group in order', ->
            slugs = []
            modVersion.eachItemInGroup 'letter', (item)-> slugs.push item.slug.qualified
            slugs.should.eql ['test__alpha', 'test__bravo']

            slugs = []
            modVersion.eachItemInGroup 'number', (item)-> slugs.push item.slug.qualified
            slugs.should.eql ['test__one', 'test__two']


    describe 'findItemByName', ->

        it 'locates items by slugified name', ->
            modVersion.addItem new Item name:'Crafting Table'
            modVersion.findItemByName('Crafting Table').slug.qualified.should.equal 'test__crafting_table'

    describe 'findRecipes', ->

        beforeEach ->
            modVersion = new ModVersion modSlug:'test', version:'1.0'
            modVersion.parse """
                schema:1

                item: Cake
                    recipe:; input: Milk, Sugar, Egg, Wheat; pattern: 000 121 333; extras: 3 Bucket
                    recipe:; input: Milk, Cocoa Beans, Egg, Wheat; pattern: 000 121 333; extras: 3 Bucket
                    recipe:; input: Cake Slice; pattern: 000 000 000; onlyIf: item Cake Slice
                item: Bucket
                    recipe:; input: Iron Ingot; pattern: ... 0.0 .0.
            """

        it 'finds all recipes which list item as output', ->
            recipes = modVersion.findRecipes ItemSlug.slugify('test__bucket')
            (r.output[0].itemSlug.item for r in recipes).sort().should.eql ['bucket', 'cake', 'cake']

        it 'skip recipes whose conditions are not met', ->
            recipes = modVersion.findRecipes ItemSlug.slugify('test__cake')
            recipes.length.should.equal 2
