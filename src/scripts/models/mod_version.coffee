###
Crafting Guide - mod_version.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel      = require './base_model'
{Event}        = require '../constants'
Item           = require './item'
ItemSlug       = require './item_slug'
{RequiredMods} = require '../constants'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class ModVersion extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.modSlug? then throw new Error 'attributes.modSlug is required'
        if not attributes.version? then throw new Error 'attributes.version is required'
        attributes.mod ?= null
        super attributes, options

        @_groups  = {}
        @_items   = {}
        @_names   = {}
        @_recipes = {}
        @_slugs   = []

    # Public Methods ###############################################################################

    compareTo: (that)->
        if this.mod? and that.mod?
            return this.mod.compareTo that.mod

        if this.modSlug isnt that.modSlug
            return if this.modSlug < that.modSlug then -1 else +1

        return 0

    sort: ->
        @_slugs.sort (a, b)-> ItemSlug.compare a, b

    # Item Methods #################################################################################

    addItem: (item)->
        if @findItem(item.slug)? then throw new Error "duplicate item for #{item.name}"

        item.modVersion = this
        @_items[item.slug.item] = item
        @_groups[item.group] ?= {}
        @_groups[item.group][item.slug.item] = item

        @registerName item.slug, item.name
        return this

    allItemsInGroup: (group)->
        result = []
        @eachItemInGroup group, (item)-> result.push item
        return null if result.length is 0
        return result

    eachItem: (callback)->
        for slug in @_slugs
            item = @findItem slug
            continue unless item?
            callback item
        return this

    eachItemInGroup: (group, callback)->
        itemMap = @_groups[group]
        return unless itemMap?

        items = _.values(itemMap).sort (a, b)-> a.compareTo b
        for item in items
            callback item

    findItem: (itemSlug)->
        return @_items[itemSlug.item]

    findItemByName: (name)->
        for itemSlug, item of @_items
            return item if item.name is name
        return null

    # Group Methods ################################################################################

    eachGroup: (callback)->
        groupNames = _.keys @_groups
        groupNames.sort (a, b)->
            if a is b then return 0
            if a is Item.Group.Other then return -1
            if b is Item.Group.Other then return +1
            return if a < b then -1 else +1

        for groupName in groupNames
            callback groupName

    # Name Methods #################################################################################

    eachName: (callback)->
        for slug in @_slugs
            callback @_names[slug.item], slug
        return this

    findName: (itemSlug)->
        return @_names[itemSlug.item]

    registerName: (itemSlug, name)->
        return if @_names[itemSlug.item]
        @_names[itemSlug.item] = name
        @_slugs.push itemSlug
        return this

    # Recipe Methods ###############################################################################

    addRecipe: (recipe)->
        recipe.modVersion = this

        for stack in recipe.output
            recipeList = @_recipes[stack.itemSlug.item]
            if not recipeList?
                recipeList = @_recipes[stack.itemSlug.item] = []
            recipeList.push recipe

        return this

    eachRecipe: (callback)->
        for itemSlugText, recipeList of @_recipes
            for recipe in recipeList
                callback recipe

    findRecipes: (itemSlug, result=[])->
        for k, recipeList of @_recipes
            for recipe in recipeList
                if recipe.produces itemSlug
                    result.push recipe

        return result

    findExternalRecipes: ->
        result = {}
        for itemSlug in @_slugs
            continue if itemSlug.isQualified
            recipes = @_recipes[itemSlug.item]
            continue unless recipes? and recipes.length > 0

            resultList = result[itemSlug] = []
            for recipe in recipes
                resultList.push recipe

        return result

    hasRecipes: (itemSlug)->
        recipeList = @_recipes[itemSlug.item]
        return true if recipeList? and recipeList.length > 0
        return false

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
            modSlug:#{@modSlug}, version:#{@version}, items:«#{@_slugs.length} items»
        }"
