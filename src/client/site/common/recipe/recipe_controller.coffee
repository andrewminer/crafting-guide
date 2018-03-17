#
# Crafting Guide - recipe_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController             = require "../../base_controller"
CraftingTableController    = require "./crafting_table/crafting_table_controller"
MultiblockViewerController = require "./multiblock_viewer/multiblock_viewer_controller"
RecipeDisplay              = require "../../../models/site/recipe_display"

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
        @_router      = options.router

    # BaseController Overrides #####################################################################

    onWillChangeModel: (oldModel, newModel)->
        if not newModel? then throw new Error "model is required"
        if newModel.constructor isnt RecipeDisplay then throw new Error "model must be a RecipeDisplay"
        if @_typeController? then @_typeController.model = newModel
        return super oldModel, newModel

    refresh: ->
        return unless @model?
        @_refreshRecipeType()
        super

    # Private Methods ##############################################################################

    _lookupControllerFor: (recipeType)->
        if recipeType is RecipeDisplay::RECIPE_TYPE.CRAFTING_TABLE then return CraftingTableController
        if recipeType is RecipeDisplay::RECIPE_TYPE.MULTIBLOCK then return MultiblockViewerController

    _refreshRecipeType: ->
        return if @_renderedRecipeType is @model.type
        @_renderedRecipeType = @model.type

        if @_typeController?
            @_typeController.remove()
            @_typeController = null

        return unless @_renderedRecipeType?

        TypeController = @_lookupControllerFor @model.type

        @$el.append "<div class=\"view__#{@model.type}\"></div>"
        options = imageLoader:@_imageLoader, model:@model, modPack:@_modPack, router:@_router
        @_typeController = @addChild TypeController, ".view__#{@model.type}", options
