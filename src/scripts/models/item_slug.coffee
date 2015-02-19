###
Crafting Guide - item_slug.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

{RequiredMods} = require '../constants'

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

    @compare: (a, b)->
        aIsRequired = a.mod in RequiredMods
        bIsRequired = b.mod in RequiredMods

        if aIsRequired isnt bIsRequired
            return -1 if aIsRequired
            return +1 if bIsRequired
        else if a.isQualified isnt b.isQualified
            return -1 if a.isQualified
            return +1 if b.isQualified
        else if a.mod isnt b.mod
            return if a.mod < b.mod then -1 else +1
        else if a.item isnt b.item
            return if a.item < b.item then -1 else +1

        return 0

    @equal: (a, b)->
        return false unless a.mod is b.mod
        return false unless a.item is b.item
        return true

    @slugify: (arg)->
        return arg if arg?.constructor?.name is 'ItemSlug'

        [modSlug, itemSlug] = _.decomposeSlug arg
        itemSlug = _.slugify itemSlug

        if modSlug?
            return new ItemSlug modSlug, itemSlug
        else
            return new ItemSlug itemSlug

    # Public Methods ###############################################################################

    compareTo: (that)->
        return ItemSlug.compare this, that

    matches: (slug, options={exact:false})->
        return false unless slug?.constructor?.name is 'ItemSlug'

        if slug.isQualified and this.isQualified
            return slug.qualified is this.qualified
        else
            return slug.item is this.item

    # Property Methods #############################################################################

    getIsQualified: ->
        return @_mod?

    getItem: ->
        return @_item

    setItem: (item)->
        if not item? then throw new Error 'item is required'
        @_item = item

        @mod = @mod # reset @_qualified

    getMod: ->
        return @_mod

    setMod: (mod)->
        @_mod = mod
        @_qualified = if @_mod? then _.composeSlugs(@_mod, @_item) else @_item

    getQualified: ->
        return @_qualified

    Object.defineProperties @prototype,
        isQualified: { get:@prototype.getIsQualified                  }
        mod:         { get:@prototype.getMod,  set:@prototype.setMod  }
        item:        { get:@prototype.getItem, set:@prototype.setItem }
        qualified:   { get:@prototype.getQualified                    }

    # Object Overrides #############################################################################

    toString: ->
        return @_qualified

    valueOf: ->
        return @_qualified.valueOf()
