###
# Crafting Guide - inventory_parser.test.coffee
#
# Copyright (c) 2014-2015 by Redwood Labs
# All rights reserved.
###

Inventory       = require '../src/scripts/models/inventory'
InventoryParser = require '../src/scripts/models/inventory_parser'
Item            = require '../src/scripts/models/item'

########################################################################################################################

parser = null

########################################################################################################################

describe 'InventoryParser', ->

    beforeEach -> parser = new InventoryParser

    it 'returns an empty Inventory for an empty string', ->
        result = parser.parse ''
        result.toList().should.eql []

    it 'can parse a single item without quantity', ->
        result = parser.parse 'Wool'
        result.toList().should.eql ['wool']

    it 'can parse a single item with quantity', ->
        result = parser.parse '4 wool'
        result.toList().should.eql [[4, 'wool']]

    it 'can parse multiple mixed-type items', ->
        result = parser.parse '4 Wool\n10 String\nBoat\n\n'
        result.toList().should.eql ['boat', [10, 'string'], [4, 'wool']]

    it 're-uses the given inventory object', ->
        inventory = new Inventory
        inventory.add 'string', 8
        result = parser.parse '4 Wool', inventory
        result.toList().should.eql [[8, 'string'], [4, 'wool']]
