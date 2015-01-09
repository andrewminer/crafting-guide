###
Crafting Guide - item.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Item extends BaseModel

    @DEFAULT_STACK_SIZE = 64

    constructor: (attributes={}, options={})->
        if not attributes.name? then throw new Error 'attributes.name is required'

        attributes.isGatherable ?= false
        attributes.modVersion   ?= null
        attributes.recipes      ?= []
        attributes.slug         ?= _.slugify attributes.name
        attributes.stackSize    ?= Item.DEFAULT_STACK_SIZE
        super attributes, options

    Object.defineProperty @prototype, 'isCraftable', get:-> @recipes.length > 0

    # Public Methods ###############################################################################

    addRecipe: (recipe)->
        slug = recipe.output[0].itemSlug
        if slug isnt @slug then throw new Error "invalid recipe for #{@slug} because it makes a #{slug}"

        @recipes.push recipe

    compareTo: (that)->
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

        if @stackSize isnt Item.DEFAULT_STACK_SIZE
            result.push ', stackSize:'; result.push @stackSize

        if @recipes.length > 0
            result.push ', recipes:'
            result.push @recipes.length
            result.push ' items'

        result.push '}'
        return result.join ''
