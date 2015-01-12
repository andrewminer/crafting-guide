###
Crafting Guide - inventory.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Event}   = require '../constants'
Stack     = require './stack'

########################################################################################################################

module.exports = class Inventory extends BaseModel

    constructor: (attributes={}, options={})->
        super attributes, options
        @clear()

    Object.defineProperty @prototype, 'isEmpty', get:-> @_slugs.length is 0

    # Public Methods ###############################################################################

    add: (itemSlug, quantity=1)->
        @_add itemSlug, quantity
        @trigger Event.add, this, itemSlug, quantity
        @trigger Event.change, this
        return this

    addInventory: (inventory)->
        inventory.each (stack)=> @_add stack.itemSlug, stack.quantity
        @trigger Event.change, this
        return this

    clear: ->
        @_stacks = {}
        @_slugs = []
        @trigger 'change', self

    clone: ->
        inventory = new Inventory
        @each (stack)-> inventory.add stack.itemSlug, stack.quantity
        return inventory

    each: (onStack)->
        for itemSlug in @_slugs
            stack = @_stacks[itemSlug]
            onStack stack

    getStack: (itemSlug)->
        return @_stacks[itemSlug]

    hasAtLeast: (itemSlug, quantity=1)->
        if quantity is 0 then return true

        stack = @_stacks[itemSlug]
        return false unless stack?
        return stack.quantity >= quantity

    pop: ->
        itemSlug = @_slugs.pop()
        return null unless itemSlug?

        stack = @_stacks[itemSlug]
        delete @_stacks[itemSlug]

        @trigger Event.remove, this, stack.itemSlug, stack.quantity
        @trigger Event.change, this
        return stack

    quantityOf: (itemSlug)->
        stack = @_stacks[itemSlug]
        return 0 unless stack?
        return stack.quantity

    remove: (itemSlug, quantity=1)->
        return if quantity is 0

        stack = @_stacks[itemSlug]
        if not stack? then throw new Error "cannot remove #{itemSlug} since it is not in this inventory"
        if stack.quantity < quantity
            throw new Error "cannot remove #{quantity}: only #{stack.quantity} #{itemSlug} in this inventory"

        stack.quantity -= quantity
        if stack.quantity is 0
            delete @_stacks[itemSlug]
            @_slugs = _(@_slugs).without itemSlug

        @trigger Event.remove, this, itemSlug, quantity
        @trigger Event.change, this
        return this

    toList: ->
        result = []
        @each (stack)->
            if stack.quantity > 1
                result.push [stack.quantity, stack.itemSlug]
            else
                result.push stack.itemSlug
        return result

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") { items: ["]

        needsDelimiter = false
        @each (stack)->
            if needsDelimiter then result.push ', '
            result.push stack.toString()
            needsDelimiter = true
        result.push ']'

        result.push '}'
        return result.join ''

    # Private Methods ##############################################################################

    _add: (itemSlug, quantity=1)->
        return if quantity is 0

        stack = @_stacks[itemSlug]
        if not stack?
            stack = new Stack itemSlug:itemSlug, quantity:quantity
            @_stacks[itemSlug] = stack
            @_slugs.push itemSlug
            @_slugs.sort()
        else
            stack.quantity += quantity
