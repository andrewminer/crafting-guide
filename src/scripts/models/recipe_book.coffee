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
        attributes.enabled     ?= true
        super attributes, options

    # Public Methods ###############################################################################

    gatherNames: (result)->
        return unless @enabled

        for recipe in @recipes
            continue if result[recipe.name]
            result[recipe.name] = value:recipe.name, label:"#{recipe.name} (from #{@modName} #{@modVersion})"

        return result

    gatherRecipes: (name, result)->
        return unless @enabled

        for recipe in @recipes
            if recipe.name is name
                result.push recipe

        return result

    hasRecipe: (name)->
        for recipe in @recipes
            return true if recipe.name is name
        return false

    # Object Overrides #############################################################################

    toString: ->
        return "RecipeBook (#{@cid}) {
            enabled:#{@enabled},
            modName:#{@modName},
            modVersion:#{@modVersion},
            recipes:#{@recipes.length} items}"
