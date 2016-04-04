#
# Crafting Guide - inventory.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

EventRecorder = require '../event_recorder'
Inventory     = require './inventory'
Item          = require './item'
ItemSlug      = require './item_slug'

########################################################################################################################

inventory = modPack = null

########################################################################################################################

describe 'inventory.coffee', ->

    beforeEach ->
        inventory = new Inventory {}, silent:false
        inventory.add ItemSlug.slugify('wool'), 4
        inventory.add ItemSlug.slugify('string'), 20
        inventory.add ItemSlug.slugify('boat')

    describe 'add', ->

        it 'can add to an empty inventory', ->
            inventory.add ItemSlug.slugify('iron_ingot'), 4
            stack = inventory._stacks['iron_ingot']
            stack.constructor.name.should.equal 'Stack'
            stack.itemSlug.qualified.should.equal 'iron_ingot'
            stack.quantity.should.equal 4

        it 'can augment quantity of existing items', ->
            inventory.add ItemSlug.slugify('wool'), 2
            inventory.unparse().should.equal 'boat:20.string:6.wool'

        it 'can add zero quantity', ->
            inventory.add ItemSlug.slugify('wool'), 0
            inventory.unparse().should.equal 'boat:20.string:4.wool'

        it 'emits the proper events', ->
            events = new EventRecorder inventory
            inventory.add ItemSlug.slugify('iron_ingot'), 10
            events.names.should.eql [c.event.add, c.event.change]

    describe 'addInventory', ->

        it 'can add to an empty inventory', ->
            newInventory = new Inventory
            newInventory.addInventory inventory
            newInventory.unparse().should.equal 'boat:20.string:4.wool'

        it 'can add a mix of new and existing items', ->
            newInventory = new Inventory
            newInventory.add ItemSlug.slugify('string'), 2
            newInventory.addInventory inventory
            newInventory.unparse().should.equal 'boat:22.string:4.wool'

    describe 'clone', ->

        it 'creates an empty inventory from an empty inventory', ->
            a = new Inventory
            b = a.clone()
            b._itemSlugs.should.eql []

        it 'faithfully copies an existing inventory', ->
            copy = inventory.clone()
            copy.unparse().should.equal 'boat:20.string:4.wool'

    describe 'each', ->

        it 'works with an empty inventory', ->
            inventory = new Inventory
            result = []
            inventory.each (item)-> result.push item.name
            result.should.eql []

        it 'works when items have only been added', ->
            result = []
            inventory.each (stack)-> result.push stack.itemSlug.qualified
            result.should.eql ['boat', 'string', 'wool']

        it 'works when items have been augmented', ->
            inventory.add ItemSlug.slugify 'iron_ingot'
            inventory.add ItemSlug.slugify 'boat'
            inventory.add ItemSlug.slugify('wool'), 2

            result = []
            inventory.each (stack)-> result.push stack.itemSlug.qualified
            result.should.eql ['boat', 'iron_ingot', 'string', 'wool']

    describe 'hasAtLeast', ->

        it 'works when the item is completely absent', ->
            answer = inventory.hasAtLeast 'chicken', 1
            answer.should.be.false

        it 'always returns true for zero quantity', ->
            inventory.hasAtLeast('chicken', 0).should.be.true
            inventory.hasAtLeast('wool', 0).should.be.true

        it 'works for a quantity above 1', ->
            inventory.hasAtLeast('wool', 3).should.be.true
            inventory.hasAtLeast('wool', 4).should.be.true
            inventory.hasAtLeast('wool', 5).should.be.false

    describe 'localize', ->

        before ->
            modPack =
                modSlug:
                    wool:       'minecraft'
                    string:     'minecraft'
                    boat:       'minecraft'
                    stone_gear: 'buildcraft'
                findItem: (slug)->
                    return slug:new ItemSlug @modSlug[slug.item], slug.item

        it 'replaces item slugs with qualified slugs', ->
            inventory.add ItemSlug.slugify 'stone_gear'
            inventory.modPack = modPack
            inventory.localize()

            slugs = []
            inventory.each (stack)-> slugs.push stack.itemSlug.qualified
            slugs.should.eql [
                'minecraft__boat'
                'buildcraft__stone_gear'
                'minecraft__string'
                'minecraft__wool'
            ]

        it 'ignores qualified slugs', ->
            inventory.add ItemSlug.slugify 'buildcraft__stone_gear'
            inventory.modPack = modPack
            inventory.localize()

            slugs = []
            inventory.each (stack)-> slugs.push stack.itemSlug.qualified
            slugs.should.eql [
                'minecraft__boat'
                'buildcraft__stone_gear'
                'minecraft__string'
                'minecraft__wool'
            ]

    describe 'parse', ->

        beforeEach ->
            inventory = new Inventory {}, silent:false

        it 'ignores an empty string', ->
            result = inventory.parse ''
            result.unparse().should.eql ''

        it 'can parse a single item without quantity', ->
            result = inventory.parse 'wool'
            result.unparse().should.equal 'wool'

        it 'can parse a single item with quantity', ->
            result = inventory.parse '4.wool'
            result.unparse().should.equal '4.wool'

        it 'can parse multiple mixed-type items', ->
            result = inventory.parse '4.wool:10.string:boat'
            result.unparse().should.equal 'boat:10.string:4.wool'

    describe 'pop', ->

        it 'returns null for an empty inventory', ->
            inventory = new Inventory
            result = inventory.pop()
            expect(result).to.be.null

        it 'completely removes the last item', ->
            stack = inventory.pop()
            stack.itemSlug.qualified.should.equal 'wool'
            stack.quantity.should.equal 4
            inventory.unparse().should.equal 'boat:20.string'

        it 'triggers the right events', ->
            events = new EventRecorder inventory
            result = inventory.pop()
            events.names.should.eql [c.event.remove, c.event.change]

    describe 'remove', ->

        it 'does nothing when the item is absent', ->
            before = inventory.unparse()
            inventory.remove 'foo'
            after = inventory.unparse()

            before.should.equal after

        it 'throws when the item has insufficient quantity', ->
            expect(-> inventory.remove('wool', 10)).to.throw Error,
                'cannot remove 10: only 4 wool in this inventory'

        it 'removes all items by default', ->
            inventory.remove 'wool'
            expect(inventory._stacks.wool).to.be.empty

        it 'removes a quantity above 1', ->
            inventory.remove 'wool', 3
            inventory._stacks.wool.quantity.should.equal 1

        it 'emits the proper events', ->
            events = new EventRecorder inventory
            inventory.remove 'wool'
            events.names.should.eql [c.event.change, c.event.remove, c.event.change]
