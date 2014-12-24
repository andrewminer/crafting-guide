###
# Crafting Guide - inventory_parser.test.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

Inventory       = require '../src/scripts/models/inventory'
InventoryParser = require '../src/scripts/models/inventory_parser'

########################################################################################################################

parser = null

########################################################################################################################

describe 'InventoryParser', ->

    beforeEach -> parser = new InventoryParser

    it 'returns an empty Inventory for an empty string', ->
        result = parser.parse ''
        result._names.length.should.equal 0

    it 'can parse a single item without quantity', ->
        result = parser.parse 'wool'
        result._items.wool.quantity.should.equal 1

    it 'can parse a single item with quantity', ->
        result = parser.parse '4 wool'
        result._items.wool.quantity.should.equal 4

    it 'can parse multiple mixed-type items', ->
        result = parser.parse '4 wool\n10 string\nboat\n\n'
        result._items.wool.quantity.should.equal 4
        result._items.string.quantity.should.equal 10
        result._items.boat.quantity.should.equal 1
        result._names.should.eql ['wool', 'string', 'boat']

    it 're-uses the given inventory object', ->
        inventory = new Inventory
        inventory.add 'string', 8
        result = parser.parse '4 wool', inventory
        inventory._items.string.quantity.should.equal 8
        inventory._items.wool.quantity.should.equal 4
        inventory._names.should.eql ['string', 'wool']
