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
        if not attributes.modSlug? then throw new Error 'attributes.modSlug is required'
        if not attributes.version? then throw new Error 'attributes.version is required'
        attributes.mod ?= null
        super attributes, options

        @_groups = {}
        @_items  = {}
        @_names  = {}
        @_slugs  = []

    # Public Methods ###############################################################################

    addItem: (item)->
        if @_items[item.slug]? then throw new Error "duplicate item for #{item.name}"

        @_items[item.slug]               = item
        @_groups[item.group]            ?= {}
        @_groups[item.group][item.slug]  = item

        item.modVersion = this
        @registerSlug item.slug, item.name
        return this

    allItemsInGroup: (group)->
        result = []
        @eachItemInGroup group, (item)-> result.push item
        return null if result.length is 0
        return result

    compareTo: (that)->
        if this.mod? and that.mod?
            return this.mod.compareTo that.mod

        if this.modSlug isnt that.modSlug
            return if this.modSlug < that.modSlug then -1 else +1

        return 0

    eachGroup: (callback)->
        groupNames = _.keys @_groups
        groupNames.sort (a, b)->
            if a is b then return 0
            if a is Item.Group.Other then return -1
            if b is Item.Group.Other then return +1
            return if a < b then -1 else +1

        for groupName in groupNames
            callback groupName

    eachItem: (callback)->
        for slug in @_slugs
            item = @_items[slug]
            continue unless item?
            callback @_items[slug], slug
        return this

    eachItemInGroup: (group, callback)->
        group = @_groups[group]
        return unless group?

        for slug in _.keys(group).sort()
            callback group[slug]

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

    findRecipes: (itemSlug, result=[])->
        for slug in @_slugs
            item = @_items[slug]
            continue unless item?

            item.eachRecipe (recipe)->
                result.push recipe if recipe.doesProduce itemSlug
        return result

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
        ModVersionParser = require './mod_version_parser' # to avoid require cycles
        @_parser ?= new ModVersionParser model:this
        @_parser.parse text

        return null # prevent calling `set`

    url: ->
        return Url.modVersion modSlug:@modSlug, modVersion:@version

    # Object Overrides #############################################################################

    toString: ->
        return "ModVersion (#{@cid}) {
            modSlug:#{@modSlug}, version:#{@version}, items:#{_.keys(@_items).length} items
        }"
