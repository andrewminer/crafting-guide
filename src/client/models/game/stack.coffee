#
# Crafting Guide - stack.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class Stack

    constructor: (attributes={})->
        @item = attributes.item
        @quantity = attributes.quantity

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        item:
            get: -> return @_item
            set: (item)->
                if not item? then throw new Error "item is required"
                if @_item is item then return
                if @_item? then throw new Error "item cannot be reassigned"
                @_item = item

        modPack:
            get: -> return @_item.modPack
            set: -> throw new Error "modPack cannot be replaced"

        quantity:
            get: -> return @_quantity
            set: (quantity)->
                quantity = parseInt "#{quantity}"
                quantity = if Number.isNaN(quantity) then 0 else Math.max(0, quantity)
                @_quantity = quantity

    # Object Overrides #############################################################################

    toString: ->
        return "Stack:#{@item}×#{@quantity}"