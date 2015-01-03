###
# Crafting Guide - inventory.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
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

    add: (item, quantity=1)->
        return if quantity is 0

        stack = @_stacks[item.slug]
        if not stack?
            stack = new Stack item:item, quantity:quantity
            @_stacks[item.slug] = stack
            @_slugs.push item.slug
            @_slugs.sort()
        else
            stack.quantity += quantity

        @trigger Event.add, this, item, quantity
        @trigger Event.change, this
        return this

    addInventory: (inventory)->
        inventory.each (stack)=> @add stack.item, stack.quantity
        return this

    clear: ->
        @_stacks = {}
        @_slugs = []

    clone: ->
        inventory = new Inventory
        @each (stack)-> inventory.add stack.item, stack.quantity
        return inventory

    each: (onItem)->
        for slug in @_slugs
            stack = @_stacks[slug]
            onItem stack

    hasAtLeast: (slug, quantity=1)->
        if quantity is 0 then return true

        stack = @_stacks[slug]
        return false unless stack?
        return stack.quantity >= quantity

    pop: ->
        slug = @_slugs.pop()
        return null unless slug?

        stack = @_stacks[slug]
        delete @_stacks[slug]

        @trigger Event.remove, this, stack.item, stack.quantity
        @trigger Event.change, this
        return stack

    quantityOf: (slug)->
        stack = @_stacks[slug]
        return 0 unless stack?
        return stack.quantity

    remove: (slug, quantity=1)->
        return if quantity is 0

        stack = @_stacks[slug]
        if not stack? then throw new Error "cannot remove #{slug} since it is not in this inventory"
        if stack.quantity < quantity
            throw new Error "cannot remove #{quantity} #{slug} because there is only #{stack.quantity} in this inventory"

        stack.quantity -= quantity
        if stack.quantity is 0
            delete @_stacks[slug]
            @_slugs = _(@_slugs).without slug

        @trigger Event.remove, this, slug, quantity
        @trigger Event.change, this
        return this

    toList: ->
        result = []
        @each (stack)->
            if stack.quantity > 1
                result.push [stack.quantity, stack.item.slug]
            else
                result.push stack.item.slug
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
