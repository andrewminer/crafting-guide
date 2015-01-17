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
        super attributes, options

        @_modVersions = []

    # Public Methods ###############################################################################

    findItem: (slug, options={})->
        options.includeDisabled ?= false

        for modVersion in @_modVersions
            continue unless modVersion.enabled or options.includeDisabled
            item = modVersion.findItem slug
            return item if item?

        return null

    findItemByName: (name, options={})->
        options.includeDisabled ?= false
        slug = _.slugify name

        for modVersion in @_modVersions
            continue unless modVersion.enabled or options.includeDisabled
            item = modVersion.findItem slug
            return item if item?

        return null

    findName: (slug, options={})->
        options.includeDisabled ?= false

        for modVersion in @_modVersions
            continue unless modVersion.enabled or options.includeDisabled
            name = modVersion.findName slug
            return name if name

        return null

    findItemDisplay: (slug)->
        result = {}
        item = @findItem slug, includeDisabled:true
        if item?
            result.modSlug    = item.modVersion.slug
            result.modVersion = item.modVersion.version
            result.slug   = item.slug
            result.itemName   = item.name
        else
            result.modSlug    = _.slugify DefaultModVersions[0].name
            result.modVersion = DefaultModVersions[0].version
            result.slug   = slug
            result.itemName   = @findName slug, includeDisabled:true

        result.iconUrl = Url.itemIcon result
        result.itemUrl = Url.item result
        return result

    isValidName: (name, options={})->
        options.includeDisabled ?= false

        slug = _.slugify name
        for modVersion in @_modVersions
            continue unless modVersion.enabled or options.includeDisabled
            name = modVersion.findName slug
            return true if name

        return false

    # Property Methods #############################################################################

    addModVersion: (modVersion)->
        return if @_modVersions.indexOf(modVersion) isnt -1

        @_modVersions.push modVersion
        @trigger Event.add, modVersion, this

        @_modVersions.sort (a, b)-> a.compareTo b
        @trigger Event.change, this

        return this

    eachModVersion: (callback)->
        for modVersion in @_modVersions
            callback modVersion

    getModVersions: ->
        return @_modVersions[..]

    # Object Overrides #############################################################################

    toString: ->
        return "ModPack (#{@cid}) {modVersions:#{@_modVersions.length} items}"
