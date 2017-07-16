#
# Crafting Guide - recipe_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController          = require "../../base_controller"
CraftingTableController = require "./crafting_table/crafting_table_controller"

########################################################################################################################

module.exports = class RecipeController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"
        options.templateName = "common/recipe"
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_multiplier  = options.multiplier
        @_router      = options.router

    # Class Members ################################################################################
    
    @::RECIPE_TYPE =
        CRAFTING_TABLE:
            css: "crafting_table"
            Controller: CraftingTableController

    @::ALL_RECIPE_TYPES = (value for key, value of @::RECIPE_TYPE)

    # Properties ###################################################################################

    Object.defineProperties @prototype,
        multiplier:
            get: ->
                @_multiplier ?= 1
                return @_multiplier

            set: (newMultiplier)->
                oldMultiplier = @_multiplier
                return if newMultiplier is oldMultiplier

                @_multiplier = newMultiplier

                @trigger "change:multiplier", this, oldMultiplier, newMultiplier
                @trigger "change", this

        recipeType:
            get: -> return @_recipeType
            set: -> throw new Error "recipeType cannot be assigned"

    # BaseController Overrides #####################################################################

    onWillChangeModel: (oldModel, newModel)->
        @_recomputeRecipeType(newModel)
        return super oldModel, newModel

    refresh: ->
        @_refreshRecipeType()

    # Private Methods ##############################################################################

    _recomputeRecipeType: (recipe)->
        oldRecipeType = @_recipeType

        if not recipe?
            newRecipeType = null
        else
            newRecipeType = @RECIPE_TYPE.CRAFTING_TABLE

        return unless newRecipeType isnt oldRecipeType

        @_recipeType = newRecipeType
        @trigger "change:recipeType", this, oldRecipeType, newRecipeType

    _refreshRecipeType: ->
        return if @_renderedRecipeType is @recipeType
        @_renderedRecipeType = @recipeType

        if @_typeController?
            @_typeController.remove()
            @_typeController = null

        return unless @recipeType?

        @$el.append "<div class=\"view__#{@recipeType.css}\"></div>"
        options = imageLoader:@_imageLoader, model:@model, modPack:@_modPack, router:@_router
        @_typeController = @addChild @recipeType.Controller, ".view__#{@recipeType.css}", options
