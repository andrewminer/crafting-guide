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

    # Public Methods ###############################################################################

    add: (name, quantity=1)->
        item = @_items[name]
        if not item?
            item = new Item name:name, quantity:quantity
            @_items[name] = item
            @_names.push name
        else
            item.quantity += quantity

        @trigger Event.add, this, name, quantity
        @trigger Event.change, this
        return this

    clear: ->
        @_items = {}
        @_names = []

    each: (onItem)->
        for name in @_names
            item = @_items[name]
            onItem item

    hasAtLeast: (name, quantity=1)->
        if quantity is 0 then return true

        item = @_items[name]
        return false unless item?
        return item.quantity >= quantity

    remove: (name, quantity=1)->
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

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") { items: ["]

        needsDelimiter = false
        for name, item of @_items
            if needsDelimiter then result.push ', '
            result.push item.toString()
            needsDelimiter = true
        result.push ']'

        result.push '}'
        return result.join ''
