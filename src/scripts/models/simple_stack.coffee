###
Crafting Guide - simple_stack.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class Stack

    constructor: (attributes={}, options={})->
        if not attributes.itemSlug? then throw new Error 'attributes.itemSlug is required'
        attributes.quantity ?= 1

        @itemSlug = attributes.itemSlug
        @quantity = attributes.quantity

    # Object Overrides #############################################################################

    toString: ->
        return "#{@quantity} #{@itemSlug}"
