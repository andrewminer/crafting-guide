###
Crafting Guide - mod_pack.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel            = require './base_model'
{DefaultModVersions} = require '../constants'
{Event}              = require '../constants'
ModVersionParser     = require './mod_version_parser'
Recipe               = require './recipe'
{Url}                = require '../constants'

########################################################################################################################

module.exports = class ModPack extends BaseModel

    constructor: (attributes={}, options={})->
        super attributes, options

        @_mods = []

    # Public Methods ###############################################################################

    findItem: (itemSlug, options={})->
        options.includeDisabled ?= false

        if itemSlug.isQualified
            mod = @getMod itemSlug.mod
            if mod?
                item = mod.findItem itemSlug, options
                return item if item?

        for mod in @_mods
            continue unless mod.enabled or options.includeDisabled
            item = mod.findItem itemSlug, options
            return item if item?

        return null

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

        result = {}
        item = @findItem itemSlug, includeDisabled:true
        if item?
            result.modSlug    = item.slug.mod
            result.modVersion = item.modVersion.version
            result.itemSlug   = item.slug.item
            result.itemName   = item.name
        else
            result.modSlug    = @_mods[0].slug
            result.modVersion = @_mods[0].activeVersion
            result.itemSlug   = itemSlug.item
            result.itemName   = @findName itemSlug, includeDisabled:true

        result.craftingUrl = Url.crafting inventoryText:itemSlug.item
        result.iconUrl     = Url.itemIcon result
        result.itemUrl     = Url.item result
        return result

    findName: (slug, options={})->
        options.includeDisabled ?= false

        for mod in @_mods
            continue unless mod.enabled or options.includeDisabled
            name = mod.findName slug
            return name if name

        return null

    findRecipes: (itemSlug, result=[], options={})->
        options.alwaysFromOwningMod ?= false
        return null unless itemSlug?

        for mod in @_mods
            if not mod.enabled
                owningMod = itemSlug.isQualified and (itemSlug.mod is mod.slug)
                continue unless owningMod and options.alwaysFromOwningMod

            mod.findRecipes itemSlug, result, options

        return if result.length > 0 then result else null

    # Property Methods #############################################################################

    addMod: (mod)->
        if not mod? then throw new Error 'mod is required'
        return if @_mods.indexOf(mod) isnt -1

        mod.modPack = this
        @_mods.push mod
        @listenTo mod, Event.change, (modVersion)=> @_onModVersionLoaded modVersion
        @trigger Event.add + ':mod', mod, this

        @_mods.sort (a, b)-> a.compareTo b
        @trigger Event.sort + ':mod', this
        @trigger Event.change, this

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

    # Object Overrides #############################################################################

    toString: ->
        return "ModPack (#{@cid}) {modVersions:«#{@_mods.length} items»}"

    # Private Methods ##############################################################################

    _onModVersionLoaded: (modVersion)->
        stillLoading = false
        @eachMod (mod)->
            mod.eachModVersion (modVersion)->
                stillLoading = stillLoading or modVersion.isLoading

        @trigger Event.change, this if not stillLoading
