###
# Crafting Guide - recipe_book.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class RecipeBook extends BaseModel

    constructor: (attributes={}, options={})->
        if _.isEmpty(attributes.modName) then throw new Error 'modName cannot be empty'
        if _.isEmpty(attributes.modVersion) then throw new Error 'modVersion cannot be empty'

        attributes.description ?= ''
        attributes.recipes     ?= []
        super attributes, options

    # Public Methods ###############################################################################

    findRecipes: (name)->
        result = []
        for recipe in @recipes
            if recipe.name is name
                result.push recipe

        return result

    # Object Overrides #############################################################################

    toString: ->
        return "RecipeBook (#{@cid}) {
            modName:#{@modName},
            modVersion:#{@modVersion},
            recipes:#{@recipes.length} items}"
