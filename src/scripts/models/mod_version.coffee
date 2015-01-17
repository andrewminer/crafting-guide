###
Crafting Guide - mod_version.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseCollection = require './base_collection'
BaseModel      = require './base_model'
{Event}        = require '../constants'
Item           = require './item'
{RequiredMods} = require '../constants'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class ModVersion extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.name? then throw new Error 'attributes.name is required'
        if not attributes.version? then throw new Error 'attributes.version is required'

        attributes.description  ?= ''
        attributes.enabled      ?= true
        attributes.slug         ?= _.slugify attributes.name
        super attributes, options

        @_items = {}
        @_names = {}
        @_slugs = []

    # Public Methods ###############################################################################

    addItem: (item)->
        if @_items[item.slug]? then throw new Error "duplicate item for #{item.name}"

        @_items[item.slug] = item
        item.modVersion = this
        @registerSlug item.slug, item.name
        return this

    compareTo: (that)->
        if this.name is that.name then return 0

        thisRequired = this.name in RequiredMods
        thatRequired = that.name in RequiredMods

        if thisRequired and thatRequired
            return if this.name < that.name then -1 else +1
        else if thisRequired
            return -1
        else if thatRequired
            return +1
        else
            return if this.name < that.name then -1 else +1

    eachItem: (callback)->
        for slug in @_slugs
            callback @_items[slug], slug
        return this

    eachName: (callback)->
        for slug in @_slugs
            callback @_names[slug], slug
        return this

    findItem: (slug)->
        return @_items[slug]

    findItemByName: (name)->
        return @findItem _.slugify name

    findName: (slug)->
        return @_names[slug]

    registerSlug: (slug, name)->
        hasSlug = @_names[slug]?
        @_names[slug] = name

        if not hasSlug
            @_slugs.push slug
            @_slugs.sort()
            @_slugs = _.uniq @_slugs, true

        return this

    # Backbone.Model Overrides #####################################################################

    parse: (text)->
        currentSilent = @silent
        @silent = true

        ModVersionParser = require './mod_version_parser' # to avoid require cycles
        @_parser ?= new ModVersionParser model:this
        @_parser.parse text

        @silent = currentSilent
        @trigger Event.change, this

        return null # prevent calling `set`

    url: ->
        return Url.modVersion modSlug:@slug, modVersion:@version

    # Object Overrides #############################################################################

    toString: ->
        return "ModVersion (#{@cid}) {
            enabled:#{@enabled},
            name:#{@name},
            version:#{@version},
            items:#{_.keys(@_items).length} items
        }"
