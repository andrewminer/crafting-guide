#
# Crafting Guide - simple_stack.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ItemSlug = require '../game/item_slug'

########################################################################################################################

module.exports = class Stack

    constructor: (attributes={}, options={})->
        if not attributes.itemSlug? then throw new Error 'attributes.itemSlug is required'
        attributes.quantity ?= 1

        @itemSlug = attributes.itemSlug
        @quantity = attributes.quantity

    # Class Methods ################################################################################

    @compare: (a, b)->
        if a? and not b? then return -1
        if not a? and b? then return +1
        if a.quantity isnt b.quantity
            return if a.quantity > b.quantity then -1 else +1
        return ItemSlug.compare a.itemSlug, b.itemSlug

    # Object Overrides #############################################################################

    toString: ->
        return "#{@quantity} #{@itemSlug}"
