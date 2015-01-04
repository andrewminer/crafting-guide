###
Crafting Guide - stack.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class Stack

    constructor: (attributes={})->
        if not attributes.itemSlug? then throw new Error 'attributes.itemSlug is required'
        attributes.quantity ?= 1

        @itemSlug = attributes.itemSlug
        @quantity = attributes.quantity

    # Public Methods ###############################################################################

    canMerge: (stack)->
        return @itemSlug is stack.itemSlug

    merge: (stack)->
        if not @canMerge stack
            throw new Error "this stack of #{@itemSlug} cannot merge a stack of #{@stack.itemSlug}"

        @quantity += stack.quantity
        return this

    # Object Overrides #############################################################################

    toString: ->
        return "#{@quantity} #{@itemSlug}"
