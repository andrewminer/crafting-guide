###
# Crafting Guide - inventory.test.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

{Event}       = require '../src/scripts/constants'
EventRecorder = require './event_recorder'
Inventory     = require '../src/scripts/models/inventory'
Item          = require '../src/scripts/models/item'

########################################################################################################################

inventory = null

########################################################################################################################

describe 'Inventory', ->

    beforeEach ->
        inventory = new Inventory
        inventory.add 'wool', 4
        inventory.add 'string', 20
        inventory.add 'boat'

    describe 'add', ->

        it 'can add to an empty inventory', ->
            inventory.add 'iron ingot', 4
            item = inventory._items['iron ingot']
            item.constructor.name.should.equal 'Item'
            item.name.should.equal 'iron ingot'
            item.quantity.should.equal 4

        it 'can augment quantity of existing items', ->
            inventory.add 'wool', 2
            inventory.toList().should.eql ['boat', [20, 'string'], [6, 'wool']]

        it 'can add zero quantity', ->
            inventory.add 'wool', 0
            inventory.toList().should.eql ['boat', [20, 'string'], [4, 'wool']]

        it 'emits the proper events', ->
            events = new EventRecorder inventory
            inventory.add 'iron ingot', 10
            events.names.should.eql [Event.add, Event.change]

    describe 'addInventory', ->

        it 'can add to an empty inventory', ->
            newInventory = new Inventory
            newInventory.addInventory inventory
            newInventory._names.should.eql ['boat', 'string', 'wool']

        it 'can add a mix of new and existing items', ->
            newInventory = new Inventory
            newInventory.add 'string', 2
            newInventory.addInventory inventory
            newInventory.toList().should.eql ['boat', [22, 'string'], [4, 'wool']]

    describe 'clone', ->

        it 'creates an empty inventory from an empty inventory', ->
            a = new Inventory
            b = a.clone()
            b._names.should.eql []

        it 'faithfully copies an existing inventory', ->
            copy = inventory.clone()
            copy._names.should.eql ['boat', 'string', 'wool']
            (item.quantity for name, item of copy._items).should.eql [1, 20, 4]

    describe 'each', ->

        it 'works with an empty inventory', ->
            inventory = new Inventory
            result = []
            inventory.each (item)-> result.push item.name
            result.should.eql []

        it 'works when items have only been added', ->
            result = []
            inventory.each (item)-> result.push item.name
            result.should.eql ['boat', 'string', 'wool']

        it 'works when items have been augmented', ->
            inventory.add 'iron ingot'
            inventory.add 'boat'
            inventory.add 'wool', 2

            result = []
            inventory.each (item)-> result.push item.name
            result.should.eql ['boat', 'iron ingot', 'string', 'wool']

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

    describe 'pop', ->

        it 'returns null for an empty inventory', ->
            inventory = new Inventory
            result = inventory.pop()
            expect(result).to.be.null

        it 'completely removes the last item', ->
            result = inventory.pop()
            result.name.should.equal 'wool'
            result.quantity.should.equal 4
            inventory.toList().should.eql ['boat', [20, 'string']]

        it 'triggers the right events', ->
            events = new EventRecorder inventory
            result = inventory.pop()
            events.names.should.eql [Event.remove, Event.change]

    describe 'remove', ->

        it 'throws when the item is absent', ->
            expect(-> inventory.remove('chicken')).to.throw Error,
                'cannot remove chicken since it is not in this inventory'

        it 'throws when the item has insufficient quantity', ->
            expect(-> inventory.remove('wool', 10)).to.throw Error,
                'cannot remove 10 wool because there is only 4 in this inventory'

        it 'removes a single item by default', ->
            inventory.remove 'wool'
            inventory._items.wool.quantity.should.equal 3

        it 'removes a quantity above 1', ->
            inventory.remove 'wool', 3
            inventory._items.wool.quantity.should.equal 1

        it 'emits the proper events', ->
            events = new EventRecorder inventory
            inventory.remove 'wool'
            events.names.should.eql [Event.remove, Event.change]
