###
Crafting Guide - item_slug.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class ItemSlug

    constructor: ->
        @_item = @_mod = null
        if arguments.length is 1
            @item = arguments[0]
        else if arguments.length is 2
            @_mod = arguments[0]
            @item = arguments[1]
        else
            throw new Error 'expected arguments to be "modSlug, itemSlug" or just "itemSlug"'

    # Class Methods ################################################################################

    DELIMITER = '__'

    @compare: (a, b)->
        if a.isQualified isnt b.isQualified
            return -1 if a.isQualified
            return +1 if b.isQualified
        else if a.mod isnt b.mod
            return if a.mod < b.mod then -1 else +1
        else if a.item isnt b.item
            return if a.item < b.item then -1 else +1

        return 0

    @equals: (a, b)->
        return false unless a.mod is b.mod
        return false unless a.item is b.item
        return true

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        isQualified: { get:@prototype.isQualified }
        mod:         { get:@prototype.getMod,      set:@prototype.setMod       }
        item:        { get:@prototype.getItem,     set:@prototype.setItem      }
        qualified:   { get:@prototype.getQualified set:@prototype.setQualified }

    getItem: ->
        return @_item

    setItem: (item)->
        if not item? then throw new Error 'item is required'
        @_item = item
        @mod = mod

    getMod: ->
        return @_mod

    setMod: (mod)->
        @_qualified = if mod? then "#{@mod}#{ItemSlug.DELIMITER}#{@item}" else @item
        @_mod = mod

    isQualified: ->
        return @_mod?

    # Object Overrides #############################################################################

    toString: ->
        return @_qualified

    valueOf: ->
        return @_qualified.valueOf()
