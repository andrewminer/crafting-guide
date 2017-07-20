#
# Crafting Guide - step_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController      = require "../../base_controller"
{Inventory}         = require("crafting-guide-common").models
{CraftingPlanStep}  = require("crafting-guide-common").crafting
InventoryController = require "../../common/inventory/inventory_controller"
RecipeController    = require "../../common/recipe/recipe_controller"
RecipeDisplay       = require "../../../models/site/recipe_display"

########################################################################################################################

module.exports = class StepController extends BaseController

    constructor: (options={})->
        if options.model?.constructor isnt CraftingPlanStep
            throw new Error "options.model must be a CraftingPlanStep"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        options.templateName = "craft_page/step"
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

        @canAddTools = options.canAddTools or (controller)-> true
        @canComplete = options.canComplete or (controller)-> true
        @onComplete  = options.onComplete or (controller)-> # do nothing
        @onAddTools  = options.onAddTools or (controller)-> # do nothing

    # Public Methods ###############################################################################

    markComplete: (targetInventory)->
        @$el.addClass "complete"
        @$completeButton.addClass "disabled"
        @model.completeInto targetInventory

    # Event Methods ################################################################################

    onCompleteButtonClicked: (event)->
        return false if @$completeButton.hasClass "disabled"
        tracker.trackEvent c.tracking.category.craft, "mark-complete", null, @model.count
        @onComplete this

    onShowToolPlan: (event)->
        return false if @$toolButton.hasClass "disabled"
        tracker.trackEvent c.tracking.category.navigate, "show-tool-plan", @$toolButton.attr "target"
        return true

    # BaseController Overrides #####################################################################

    onDidRender: ->
        options = imageLoader:@_imageLoader, modPack:@_modPack, router:@_router
        @recipeController = @addChild RecipeController, ".view__recipe", options

        @$completeButton  = @$(".button.complete")
        @$header          = @$("h3")
        @$toolButton      = @$(".button.tool")
        @$toolButtonLabel = @$(".button.tool p")
        super

    onWillChangeModel: (oldModel, newModel)->
        if not newModel? then throw new Error "model cannot be null"
        if @rendered
            @$el.removeClass "complete"
            @$completeButton.removeClass "disabled"
        return super

    refresh: ->
        @$header.html "#{@model.number}. #{@model.recipe.output.item.displayName}"

        @recipeController.model = new RecipeDisplay
            multiplier:         @model.count
            recipe:             @model.recipe
            showInputInventory: true
            showOutputSlot:     true

        @_refreshCompleteButton()
        @_refreshToolButton()

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            "click .button.complete": "onCompleteButtonClicked"
            "click .button.tool":     "onShowToolPlan"

    # Private Methods ##############################################################################

    _refreshToolButton: ->
        inventory = new Inventory
        for itemId, item of @model.recipe.tools
            inventory.add item

        inventoryText = inventory.toUrlString()
        @$toolButton.attr "href", "/craft/#{inventoryText}"
        @$toolButton.attr "target", inventoryText

        if @canAddTools this
            @$toolButton.removeClass "disabled"
        else
            @$toolButton.addClass "disabled"

    _refreshCompleteButton: ->
        if @canComplete this
            @$completeButton.removeClass "disabled"
        else
            @$completeButton.addClass "disabled"
