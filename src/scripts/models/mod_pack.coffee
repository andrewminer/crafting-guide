###
Crafting Guide - mod_pack.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel            = require './base_model'
{Event}              = require '../constants'
ModVersionParser     = require './mod_version_parser'
{DefaultModVersions} = require '../constants'
{Url}                = require '../constants'

########################################################################################################################

module.exports = class ModPack extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.modVersions ?= []
        super attributes, options

    # Public Methods ###############################################################################

    addModVersion: (modVersion)->
        if modVersion.modPack isnt this then throw new Error "the mod version must be associated with this mod pack"
        return if @modVersions.indexOf(modVersion) isnt -1

        @modVersions.push modVersion
        @trigger Event.add, modVersion, this

        @modVersions.sort (a, b)-> a.compareTo b
        @trigger Event.sort, this
        @trigger Event.change, this
        return this

    enableModsForItem: (name)->
        for modVersion in @modVersions
            continue if modVersion.enabled
            if modVersion.hasRecipe name
                modVersion.enabled = true

    findItem: (itemSlug, options={})->
        options.includeDisabled ?= false

        for modVersion in @modVersions
            continue unless modVersion.enabled or options.includeDisabled
            item = modVersion.items[itemSlug]
            return item if item?

        return null

    findItemByName: (name, options={})->
        options.includeDisabled ?= false

        for modVersion in @modVersions
            continue unless modVersion.enabled or options.includeDisabled
            item = modVersion.findItemByName name
            return item if item?

        return null

    findName: (slug, options={})->
        options.includeDisabled ?= false

        for modVersion in @modVersions
            continue unless modVersion.enabled or options.includeDisabled
            name = modVersion.findName slug
            return name if name

        return slug

    findItemDisplay: (slug)->
        result = {}
        item = @findItem slug, includeDisabled:true
        if item?
            result.modSlug    = item.modVersion.slug
            result.modVersion = item.modVersion.version
            result.itemSlug   = item.slug
            result.itemName   = item.name
        else
            result.modSlug    = _.slugify DefaultModVersions[0].name
            result.modVersion = DefaultModVersions[0].version
            result.itemSlug   = slug
            result.itemName   = @findName slug, includeDisabled:true

        result.iconUrl = Url.itemIcon result
        result.itemUrl = Url.item result
        return result

    hasRecipe: (name, options={})->
        options.includeDisabled ?= false

        for modVersion in @modVersions
            continue unless modVersion.enabled or options.includeDisabled
            return true if modVersion.hasRecipe name

        return false

    isValidName: (name, options={})->
        options.includeDisabled ?= false

        slug = _.slugify name
        for modVersion in @modVersions
            continue unless modVersion.enabled or options.includeDisabled
            name = modVersion.findName slug
            return true if name

        return false

    # Object Overrides #############################################################################

    toString: ->
        return "ModPack (#{@cid}) {modVersions:#{@modVersions.length} items}"
