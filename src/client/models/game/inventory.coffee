#
# Crafting Guide - inventory.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'
ItemSlug  = require './item_slug'
Stack     = require './stack'

########################################################################################################################

module.exports = class Inventory extends BaseModel

    constructor: (attributes={}, options={})->
        super attributes, options
        attributes.modPack ?= null
        @clear()

        if options.clone?
            @addInventory options.clone

    # Class Methods ################################################################################

    @Delimiters =
        Item: '.'
        Stack: ':'

    # Public Methods ###############################################################################

    add: (itemSlug, quantity=1)->
        return this unless quantity > 0

        @_add itemSlug, quantity
        @trigger c.event.add, this, itemSlug, quantity
        @trigger c.event.change, this
        return this

    addInventory: (inventory)->
        inventory.each (stack)=> @_add stack.itemSlug, stack.quantity

        @trigger c.event.change, this
        return this

    clear: (options={})->
        @_stacks = {}
        @_itemSlugs = []

        @trigger c.event.change, this

    clone: ->
        inventory = new Inventory
        inventory.addInventory this
        return inventory

    each: (callback)->
        for itemSlug in @_itemSlugs
            stack = @_stacks[itemSlug]
            continue unless stack?
            callback stack

    getSlugs: ->
        return @_itemSlugs[..]

    hasAtLeast: (itemSlug, quantity=1)->
        if quantity is 0 then return true

        stack = @_stacks[itemSlug]
        return false unless stack?
        return stack.quantity >= quantity

    localize: ->
        if not @modPack? then throw new Error 'localize requires @modPack'

        changed = false
        newSlugs = []
        newStacks = []
        for itemSlug in @_itemSlugs
            stack = @_stacks[itemSlug]
            continue unless stack?

            qualifiedSlug = if itemSlug.isQualified then itemSlug else null
            if not qualifiedSlug?
                qualifiedSlug = @modPack.findItem(itemSlug)?.slug
                changed = qualifiedSlug?

            if qualifiedSlug?
                newSlugs.push qualifiedSlug
                newStacks.push new Stack itemSlug:qualifiedSlug, quantity:stack.quantity
            else
                newSlugs.push itemSlug
                newStacks.push stack

        if changed
            for itemSlug, stack of @_stacks
                @stopListening stack

            @_itemSlugs = newSlugs
            @_stacks = {}
            for stack in newStacks
                @_stacks[stack.itemSlug] = stack
                @listenTo stack, c.event.change, => @trigger c.event.change, this

            @_sort()
            @trigger c.event.change, this

    pop: ->
        itemSlug = @_itemSlugs.pop()
        return null unless itemSlug?

        stack = @_stacks[itemSlug]
        delete @_stacks[itemSlug]

        @trigger c.event.remove, this, stack.itemSlug, stack.quantity
        @trigger c.event.change, this
        return stack

    quantityOf: (itemSlug)->
        stack = @_stacks[itemSlug]
        return stack.quantity if stack
        return 0

    remove: (itemSlug, quantity=null)->
        stack = @_stacks[itemSlug]
        return this unless stack?

        quantity ?= stack.quantity
        return this unless quantity > 0

        if stack.quantity < quantity
            throw new Error "cannot remove #{quantity}: only #{stack.quantity} #{itemSlug} in this inventory"

        stack.quantity -= quantity
        if stack.quantity is 0
            @stopListening stack
            delete @_stacks[itemSlug]
            @_itemSlugs = (s for s in @_itemSlugs when not ItemSlug.equal(s, itemSlug))

        @trigger c.event.remove, this, itemSlug, quantity
        @trigger c.event.change, this
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

    Object.defineProperties @prototype,
        isEmpty:
            get: -> @_itemSlugs.length is 0

        totalQuantity:
            get: ->
                total = 0
                @each (stack)->
                    total += stack.quantity
                return total

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") {items: ["]

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
        return unless quantity > 0

        stack = @_stacks[itemSlug]
        if not stack?
            stack = new Stack itemSlug:itemSlug, quantity:quantity
            @listenTo stack, c.event.change, => @trigger c.event.change, this
            @_stacks[itemSlug] = stack
            @_itemSlugs.push itemSlug
            @_sort()
        else
            stack.quantity += quantity

    _sort: ->
        @_itemSlugs.sort (a, b)-> ItemSlug.compare a, b
