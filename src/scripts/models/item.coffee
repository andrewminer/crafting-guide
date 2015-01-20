###
Crafting Guide - item.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseCollection = require './base_collection'
BaseModel      = require './base_model'
{Event}        = require '../constants'
Recipe         = require './recipe'

########################################################################################################################

module.exports = class Item extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.name? then throw new Error 'attributes.name is required'

        attributes.isGatherable ?= false
        attributes.slug         ?= _.slugify attributes.name
        options.logEvents       ?= false
        super attributes, options

        @_recipes = []
        Object.defineProperties this,
            'isCraftable': { get:-> @_recipes.length > 0 }

    # Public Methods ###############################################################################

    addRecipe: (recipe)->
        if recipe.slug isnt @slug then throw new Error "cannot add a recipe for #{recipe.slug} to #{@slug}"
        @_recipes.push recipe

    eachRecipe: (callback)->
        for recipe in @_recipes
            callback recipe

    getPrimaryRecipe: ->
        return @_recipes[0]

    compareTo: (that)->
        if this.slug isnt that.slug
            return if this.slug < that.slug then -1 else +1
        if this.name isnt that.name
            return if this.name < that.name then -1 else +1
        return 0

    # Object Overrides #############################################################################

    toString: ->
        result = []
        result.push @constructor.name
        result.push ' ('; result.push @cid; result.push ') { '
        result.push 'name:"'; result.push @name; result.push '", '
        result.push 'isGatherable:'; result.push @isGatherable

        if _.slugify(@name) isnt @slug
            result.push ', slug:'; result.push @slug

        if @_recipes.length > 0
            result.push ', recipes:«'
            result.push @_recipes.length
            result.push ' items»'

        result.push '}'
        return result.join ''
