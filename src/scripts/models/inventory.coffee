###
# Crafting Guide - inventory.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel = require './base_model'
{Event}   = require '../constants'
Item      = require './item'

########################################################################################################################

module.exports = class Inventory extends BaseModel

    constructor: (attributes={}, options={})->
        super attributes, options
        @clear()

        Object.defineProperty this, 'isEmpty', get:-> @_names.length is 0

    # Public Methods ###############################################################################

    add: (name, quantity=1)->
        return if quantity is 0

        item = @_items[name]
        if not item?
            item = new Item name:name, quantity:quantity
            @_items[name] = item
            @_names.push name
            @_names.sort()
        else
            item.quantity += quantity

        @trigger Event.add, this, name, quantity
        @trigger Event.change, this
        return this

    addInventory: (inventory)->
        inventory.each (item)=> @add item.name, item.quantity
        return this

    clear: ->
        @_items = {}
        @_names = []

    clone: ->
        inventory = new Inventory
        @each (item)-> inventory.add item.name, item.quantity
        return inventory

    each: (onItem)->
        for name in @_names
            item = @_items[name]
            onItem item

    hasAtLeast: (name, quantity=1)->
        if quantity is 0 then return true

        item = @_items[name]
        return false unless item?
        return item.quantity >= quantity

    pop: ->
        name = @_names.pop()
        return null unless name?

        item = @_items[name]
        delete @_items[name]

        @trigger Event.remove, this, item.name, item.quantity
        @trigger Event.change, this
        return item

    quantityOf: (name)->
        item = @_items[name]
        return 0 unless item?
        return item.quantity

    remove: (name, quantity=1)->
        return if quantity is 0

        item = @_items[name]
        if not item? then throw new Error "cannot remove #{name} since it is not in this inventory"
        if item.quantity < quantity
            throw new Error "cannot remove #{quantity} #{name} because there is only #{item.quantity} in this inventory"

        item.quantity -= quantity
        if item.quantity is 0
            delete @_items[name]
            @_names = _(@_names).without name

        @trigger Event.remove, this, name, quantity
        @trigger Event.change, this
        return this

    toList: ->
        result = []
        @each (item)->
            if item.quantity > 1
                result.push [item.quantity, item.name]
            else
                result.push item.name
        return result

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") { items: ["]

        needsDelimiter = false
        @each (item)->
            if needsDelimiter then result.push ', '
            result.push item.toString()
            needsDelimiter = true
        result.push ']'

        result.push '}'
        return result.join ''
