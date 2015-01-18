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

        Object.defineProperties this,
            isEmpty: { get:-> @_slugs.length is 0 }

    # Public Methods ###############################################################################

    add: (slug, quantity=1)->
        @_add slug, quantity
        @trigger Event.add, this, slug, quantity
        @trigger Event.change, this
        return this

    addInventory: (inventory)->
        inventory.each (stack)=> @_add stack.slug, stack.quantity

        @trigger Event.change, this
        return this

    clear: (options={})->
        @_stacks = {}
        @_slugs = []

        @trigger Event.change, this

    clone: ->
        inventory = new Inventory
        inventory.addInventory this
        return inventory

    each: (callback)->
        for slug in @_slugs
            callback @_stacks[slug]

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

        @trigger Event.remove, this, stack.slug, stack.quantity
        @trigger Event.change, this
        return stack

    quantityOf: (slug)->
        stack = @_stacks[slug]
        return 0 unless stack?
        return stack.quantity

    remove: (slug, quantity=null)->
        return if quantity is 0

        stack = @_stacks[slug]
        if not stack? then throw new Error "cannot remove #{slug} since it is not in this inventory"

        quantity ?= stack.quantity
        if stack.quantity < quantity
            throw new Error "cannot remove #{quantity}: only #{stack.quantity} #{slug} in this inventory"

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
                result.push [stack.quantity, stack.slug]
            else
                result.push stack.slug
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

    _add: (slug, quantity=1)->
        return unless slug?
        return if quantity is 0

        stack = @_stacks[slug]
        if not stack?
            stack = new Stack slug:slug, quantity:quantity
            @_stacks[slug] = stack
            @_slugs.push slug
            @_slugs.sort()
        else
            stack.quantity += quantity
