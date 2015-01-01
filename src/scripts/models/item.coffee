###
Crafting Guide - item.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Item extends BaseModel

    @DEFAULT_STACK_SIZE = 64

    constructor: (attributes={}, options={})->
        attributes.name      ?= ''
        attributes.quantity  ?= 1
        attributes.stackSize ?= Item.DEFAULT_STACK_SIZE
        super attributes, options

        Object.defineProperty this, 'stackQuantity', get:@getStackQuantity

    # Public Methods ###############################################################################

    canMerge: (item)->
        return item.name is @name

    merge: (item)->
        if not @canMerge(item) then throw new Error "cannot merge #{item} into #{this}"
        @quantity += item.quantity

    toFormatHash: ->
        return result =
            name: @name
            quantity: @quantity
            stackQuantity: @stackQuantity

    # Property Methods #############################################################################

    getStackQuantity: ->
        count = 0
        extra = @quantity
        while extra > @stackSize
            extra -= @stackSize
            count += 1

        return count:count, extra:extra

    # Object Overrides #############################################################################

    toString: ->
        result = "#{@constructor.name} (#{@cid}) { name:\"#{@name}\", quantity:#{@quantity}"
        if @stackSize isnt Item.DEFAULT_STACK_SIZE
            result += ", stackSize:#{@stackSize}"
        result += ' }'
        return result
