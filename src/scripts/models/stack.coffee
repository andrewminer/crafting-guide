###
Crafting Guide - stack.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class Stack

    constructor: (attributes={})->
        if not attributes.item? then throw new Error 'item is required'
        attributes.quantity ?= 1

        @item = attributes.item
        @quantity = attributes.quantity

    Object.defineProperty @prototype, 'name', get:-> @item?.name

    Object.defineProperty @prototype, 'stackQuantity', get:@getStackQuantity

    # Public Methods ###############################################################################

    canMerge: (stack)->
        return @item.slug is stack.item.slug

    merge: (stack)->
        if not @canMerge stack
            throw new Error "this stack of #{@item.name} cannot merge a stack of #{@stack.name}"

        @quantity += stack.quantity
        return this

    # Property Methods #############################################################################

    getStackQuantity: ->
        count = 0
        extra = @quantity
        while extra > @item.stackSize
            extra -= @item.stackSize
            count += 1

        return count:count, extra:extra

    # Object Overrides #############################################################################

    toString: ->
        return "#{@quantity} #{@item.name}"
