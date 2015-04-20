###
Crafting Guide - inventory.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel      = require './base_model'
{Event}        = require '../constants'
ItemSlug       = require './item_slug'
{RequiredMods} = require '../constants'
Stack          = require './stack'

########################################################################################################################

module.exports = class Inventory extends BaseModel

    constructor: (attributes={}, options={})->
        super attributes, options
        attributes.modPack ?= null
        @clear()

    # Class Methods ################################################################################

    @Delimiters =
        Item: '.'
        Stack: ':'

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

    clear: (options={})->
        @_stacks = {}
        @_itemSlugs = []

        @trigger Event.change, this

    clone: ->
        inventory = new Inventory
        inventory.addInventory this
        return inventory

    each: (callback)->
        for itemSlug in @_itemSlugs
            callback @_stacks[itemSlug]

    getSlugs: ->
        return @_itemSlugs[..]

    hasAtLeast: (itemSlug, quantity=1)->
        if quantity is 0 then return true

        stack = @_stacks[itemSlug]
        return false unless stack?
        return stack.quantity >= quantity

    localize: ->
        if not @modPack? then throw new Error 'localize requires @modPack'

        newSlugs = []
        for itemSlug in @_itemSlugs
            stack = @_stacks[itemSlug]

            qualifiedSlug = @modPack.findItem(itemSlug)?.slug
            if qualifiedSlug?
                delete @_stacks[itemSlug]
                newSlugs.push qualifiedSlug
                @_stacks[qualifiedSlug] = stack
                stack.itemSlug = qualifiedSlug
            else
                newSlugs.push itemSlug

        @_itemSlugs = newSlugs
        @_sort()

    pop: ->
        itemSlug = @_itemSlugs.pop()
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

    remove: (itemSlug, quantity=null)->
        return if quantity is 0

        stack = @_stacks[itemSlug]
        if not stack? then throw new Error "cannot remove #{itemSlug} since it is not in this inventory"

        quantity ?= stack.quantity
        if stack.quantity < quantity
            throw new Error "cannot remove #{quantity}: only #{stack.quantity} #{itemSlug} in this inventory"

        stack.quantity -= quantity
        if stack.quantity is 0
            @stopListening stack
            delete @_stacks[itemSlug]
            @_itemSlugs = _(@_itemSlugs).without itemSlug

        @trigger Event.remove, this, itemSlug, quantity
        @trigger Event.change, this
        return this

    # Parsing Methods ##############################################################################

    parse: (data)->
        return this if not data? or data.length is 0

        stacks = data.split Inventory.Delimiters.Stack
        for stackText in stacks
            stackParts = stackText.split Inventory.Delimiters.Item
            if stackParts.length is 2
                quantity = parseInt stackParts[0], 10
                itemSlug = ItemSlug.slugify stackParts[1]
            else if stackParts.length is 1
                quantity = 1
                itemSlug = ItemSlug.slugify stackParts[0]
            else
                throw new Error "expected #{stackText} to have 0 or 1 parts"

            if itemSlug.qualified.length > 0
                @add itemSlug, quantity

        return this

    unparse: (options={})->
        parts = []
        @each (stack)=>
            slugText = stack.itemSlug.item
            if @modPack?
                item = @modPack.findItem ItemSlug.slugify slugText
                if item? and item.slug.qualified isnt stack.itemSlug.qualified
                    slugText = stack.itemSlug.qualified

            if stack.quantity is 1
                parts.push slugText
            else
                parts.push "#{stack.quantity}#{Inventory.Delimiters.Item}#{slugText}"

        return parts.join Inventory.Delimiters.Stack

    # Property Methods #############################################################################

    getIsEmpty: ->
        return @_itemSlugs.length is 0

    Object.defineProperties @prototype,
        isEmpty: { get:@prototype.getIsEmpty }

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
        return unless itemSlug?
        return if quantity is 0

        stack = @_stacks[itemSlug]
        if not stack?
            stack = new Stack itemSlug:itemSlug, quantity:quantity
            @listenTo stack, Event.change, => @trigger Event.change, this
            @_stacks[itemSlug] = stack
            @_itemSlugs.push itemSlug
            @_sort()
        else
            stack.quantity += quantity

    _sort: ->
        @_itemSlugs.sort (a, b)-> ItemSlug.compare a, b
