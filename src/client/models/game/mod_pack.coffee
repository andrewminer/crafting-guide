#
# Crafting Guide - mod_pack.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel        = require '../base_model'
Inventory        = require './inventory'
ModVersionParser = require '../parsing/mod_version_parser'
Recipe           = require './recipe'

########################################################################################################################

module.exports = class ModPack extends BaseModel

    constructor: (attributes={}, options={})->
        super attributes, options

        @_mods = []
        @_cache = {}

        @on c.event.change, => @_cache = {}

    # Item Methods #################################################################################

    findItem: (itemSlug, options={})->
        options.includeDisabled ?= false

        key = "#{itemSlug}-#{options.includeDisabled}"
        @_cache.itemBySlug ?= {}
        item = @_cache.itemBySlug[key]
        return item if item?

        if itemSlug.isQualified
            mod = @getMod itemSlug.mod
            if mod?
                item = mod.findItem itemSlug, options

        if not item?
            for mod in @_mods
                continue unless mod.enabled or options.includeDisabled
                item = mod.findItem itemSlug, options
                break if item?

        if item?
            @_cache.itemBySlug[key] = item

        return item

    findItemByName: (name, options={})->
        options.enableAsNeeded ?= false
        options.includeDisabled = true if options.enableAsNeeded

        for mod in @_mods
            continue unless mod.enabled or options.includeDisabled
            item = mod.findItemByName name, options
            return item if item?

        return null

    findItemDisplay: (itemSlug)->
        if not itemSlug? then throw new Error 'itemSlug is required'

        result = {slug:itemSlug}
        item = @findItem itemSlug, includeDisabled:true
        if item?
            result.itemName   = item.name
            result.itemSlug   = item.slug.item
            result.modSlug    = item.slug.mod
            result.modVersion = item.modVersion.version
        else
            result.itemName   = @findName itemSlug, includeDisabled:true
            result.itemSlug   = itemSlug.item
            result.modSlug    = @_mods[0].slug
            result.modVersion = @_mods[0].activeVersion

        craftingUrlInventory = new Inventory modPack:this
        if item?.multiblock?
            craftingUrlInventory.addInventory item.multiblock.inventory
        else
            craftingUrlInventory.add itemSlug

        result.craftingUrl = c.url.crafting inventoryText:craftingUrlInventory.unparse()
        result.iconUrl     = c.url.itemIcon result
        result.itemUrl     = c.url.item result
        result.modName     = @getMod(result.modSlug).name
        return result

    qualifySlug: (itemSlug)->
        return itemSlug if itemSlug.isQualified

        item = @findItem itemSlug
        return item.slug if item?
        return itemSlug

    # Mod Methods ##################################################################################

    addMod: (mod)->
        if not mod? then throw new Error 'mod is required'
        return if @_mods.indexOf(mod) isnt -1

        mod.modPack = this
        @_mods.push mod
        @listenTo mod, c.event.change, (modVersion)=> @_onModVersionLoaded modVersion
        @trigger c.event.add + ':mod', mod, this

        @_mods.sort (a, b)-> a.compareTo b
        @trigger c.event.sort + ':mod', this
        @trigger c.event.change, this

        return this

    eachMod: (callback)->
        for mod in @_mods
            callback mod

    getMod: (slug)->
        for mod in @_mods
            return mod if mod.slug is slug
        return null

    getAllMods: ->
        return @_mods[..]

    # Name Methods #################################################################################

    findName: (slug, options={})->
        options.includeDisabled ?= false

        for mod in @_mods
            continue unless mod.enabled or options.includeDisabled
            name = mod.findName slug
            return name if name

        return null

    # Recipe Methods ###############################################################################

    findRecipes: (itemSlug, options={})->
        options.alwaysFromOwningMod ?= false
        return null unless itemSlug?

        key = "#{itemSlug}-#{options.alwaysFromOwningMod}"
        @_cache.recipesBySlug ?= {}
        result = @_cache.recipesBySlug[key]
        return result if result?

        result = []
        for mod in @_mods
            if not mod.enabled
                owningMod = itemSlug.isQualified and (itemSlug.mod is mod.slug)
                continue unless owningMod and options.alwaysFromOwningMod

            mod.findRecipes itemSlug, result, options

        @_cache.recipesBySlug[key] = result
        return if result.length > 0 then result else null

    # Object Overrides #############################################################################

    toString: ->
        return "ModPack (#{@cid}) {modVersions:«#{@_mods.length} items»}"

    # Private Methods ##############################################################################

    _onModVersionLoaded: (modVersion)->
        working = true
        @eachMod (mod)->
            mod.eachModVersion (modVersion)->
                working = working and (modVersion.isUnloaded or modVersion.isLoading)

        return if working

        @trigger c.event.change, this
        @trigger c.event.sync, this
