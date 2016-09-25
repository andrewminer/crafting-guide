#
# Crafting Guide - item.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class Item

    constructor: (attributes={})->
        @id           = attributes.id
        @displayName  = attributes.displayName
        @isGatherable = attributes.isGatherable
        @mod          = attributes.mod

        @_hasPrimaryRecipe = false
        @_recipesAsPrimary = {}
        @_recipesAsExtra = {}

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        displayName:
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                @_displayName = displayName

        firstRecipe:
            get: -> return recipe for id, recipe of @recipes
            set: -> throw new Error "firstRecipe cannot be assigned"

        id:
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                return if @_id is id
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        isGatherable:
            get: ->
                return true if @_isGatherable is true
                return false if (id for id, recipe of @_recipesAsPrimary).length > 0
                return false if (id for id, recipe of @_recipesAsExtra).length > 0
                return true
            set: (isGatherable)->
                @_isGatherable = null unless isGatherable?
                @_isGatherable = !!isGatherable

        mod:
            get: -> return @_mod
            set: (mod)->
                if not mod? then throw new Error "mod is required"
                if @_mod is mod then return
                if @_mod? then throw new Error "mod cannot be reassigned"
                @_mod = mod
                @_mod.addItem this

        modPack:
            get: -> return @_mod.modPack
            set: -> throw new Error "modPack cannot be replaced"

        recipes:
            get: -> return if @_hasPrimaryRecipe then @_recipesAsPrimary else @_recipesAsExtra
            set: -> throw new Error "recipes cannot be assigned"

        recipesAsPrimary:
            get: -> return @_recipesAsPrimary
            set: -> throw new Error "recipes cannot be assigned"

        recipesAsExtra:
            get: -> return @_recipesAsExtra
            set: -> throw new Error "recipesAsExtra cannot be assigned"

    # Public Recipes ###############################################################################

    addRecipe: (recipe)->
        if recipe.output.item is this
            @_recipesAsPrimary[recipe.id] = recipe
            @_hasPrimaryRecipe = true
        else if recipe.extras[this.id] is this
            @_recipesAsExtra[recipe.id] = recipe
        else
            throw new Error "recipe<#{recipe.id}> does not produce this item<#{@id}>"

    # Object Overrides #############################################################################

    toString: ->
        return "Item:#{@displayName}<#{@id}>"
