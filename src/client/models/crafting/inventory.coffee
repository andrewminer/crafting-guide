#
# Crafting Guide - inventory.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Stack = require './stack'

########################################################################################################################

module.exports = class Inventory

    constructor: (inventory=null)->
        @_id = _.uniqueId "inventory-"
        @_stacks = {}

        if inventory? then @merge inventory

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        isEmpty:
            get: -> (id for id, stack of @_stacks).length is 0

        stacks:
            get: -> return @_stacks
            set: -> throw new Error "stacks cannot be replaced"

    # Public Methods ###############################################################################

    add: (item, quantity)->
        return unless item?
        return if quantity is 0

        existingStack = @_stacks[item.id]
        if existingStack?
            if existingStack.quantity + quantity < 0 then throw new Error "cannot have a negative quantity"
            existingStack.quantity += quantity
        else
            if quantity < 0 then throw new Error "cannot have a negative quantity"
            @_stacks[item.id] = new Stack item:item, quantity:quantity

        if @_stacks[item.id].quantity is 0
            delete @_stacks[item.id]

    clear: ->
        @_stacks = {}

    contains: (item)->
        return @_stacks[item.id]?

    getQuantity: (item)->
        existingStack = @_stacks[item.id]
        return 0 unless existingStack?
        return existingStack.quantity

    merge: (inventory)->
        for id, stack of inventory.stacks
            @add stack.item, stack.quantity

    remove: (item, quantity)->
        @add item, -1 * quantity

    # Object Overrides #############################################################################

    toString: (options={})->
        options.full ?= false

        if options.full
            result = []
            needsDelimiter = false

            stackList = (stack for itemId, stack of @_stacks)
            stackList.sort (a, b)->
                if a.item.displayName isnt b.item.displayName
                    return if a.item.displayName < b.item.displayName then -1 else +1
                return 0

            for stack in stackList
                if needsDelimiter then result.push ", "
                needsDelimiter = true

                result.push stack.quantity
                result.push " "
                result.push stack.item.displayName
            return result.join ""
        else
            return "Inventory<#{@_id}>@#{(id for id, item of @_stacks).length}"
