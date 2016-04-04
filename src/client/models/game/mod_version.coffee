#
# Crafting Guide - mod_version.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'
Item      = require './item'
ItemSlug  = require './item_slug'
Recipe    = require './recipe'

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

    getAllGroups: ->
        result = []
        @eachGroup (group)-> result.push group
        return result

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
        return unless recipe?

        recipe.modVersion = this
        if @_recipes[recipe.slug]? then throw new Error "duplicate recipe: #{recipe.slug}"

        @_recipes[recipe.slug] = recipe
        return this

    eachRecipe: (callback)->
        recipes = _.values(@_recipes).sort (a, b)-> Recipe.compareFor a, b
        for recipe in recipes
            callback recipe
        return this

    findRecipes: (itemSlug, result=[], options={})->
        options.onlyPrimary ?= false
        options.forCrafting ?= false

        primaryRecipes = []
        otherRecipes = []

        for recipe in _.values @_recipes
            continue unless recipe.isConditionSatisfied()
            continue unless recipe.hasAllTools()
            continue if options.forCrafting and recipe.ignoreDuringCrafting

            if recipe.itemSlug.matches itemSlug
                primaryRecipes.push recipe
            else if recipe.produces itemSlug
                otherRecipes.push recipe

        for recipe in primaryRecipes
            result.push recipe

        if not options.onlyPrimary
            for recipe in otherRecipes
                result.push recipe

        return result

    findExternalRecipes: ->
        result = {}
        for k, recipe of @_recipes
            continue if recipe.itemSlug.isQualified

            recipeList = result[recipe.itemSlug]
            if not recipeList then recipeList = result[recipe.itemSlug] = []

            recipeList.push recipe

        return result

    hasRecipes: (itemSlug)->
        for k, recipe of @_recipes
            return true if recipe.produces itemSlug
        return false

    # Backbone.Model Overrides #####################################################################

    parse: (text)->
        ModVersionParser = require '../parsing/mod_version_parser' # to avoid require cycles
        @_parser ?= new ModVersionParser model:this
        @_parser.parse text

        return null # prevent calling `set`

    url: ->
        return c.url.modVersionData modSlug:@modSlug, modVersion:@version

    # Object Overrides #############################################################################

    toString: ->
        return "ModVersion (#{@cid}) {
            modSlug:#{@modSlug}, version:#{@version}, items:«#{@_slugs.length} items»
        }"
