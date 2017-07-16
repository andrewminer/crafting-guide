#
# Crafting Guide - multiblock_viewer_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController       = require "../../../base_controller"
InventoryController  = require "../../inventory/inventory_controller"
MultiblockController = require "./multiblock/multiblock_controller"
RecipeDisplay        = require "../../../../models/site/recipe_display"

########################################################################################################################

module.exports = class MultiblockViewerController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"
        options.templateName = "common/recipe/multiblock_viewer"
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_hoverTimer  = null
        @_router      = options.router

    # Event Methods ################################################################################

    onBackClicked: ->
        return if @$backButton.hasClass "disabled"
        tracker.trackEvent c.tracking.category.multiblock, "back"
        @multiblockController.goBackLayer()
        @refresh()

    onNextClicked: ->
        return if @$nextButton.hasClass "disabled"
        tracker.trackEvent c.tracking.category.multiblock, "next"
        @multiblockController.goNextLayer()
        @refresh()

    onBlockHovered: (itemDisplay)->
        if itemDisplay?
            @$captionText.html itemDisplay.name
            @_imageLoader.load itemDisplay.iconUrl, @$captionIcon
        else
            @$captionText.html "&nbsp;"
            @$captionIcon.attr "src", "/images/empty.png"

    # BaseController Overrides #####################################################################

    onDidRender: ->
        baseOptions = imageLoader:@_imageLoader, modPack:@_modPack, router:@_router

        options = _.extend {editable:false}, baseOptions
        @completeInventoryController = @addChild InventoryController, ".view__inventory.complete", options
        @layerInventoryController = @addChild InventoryController, ".view__inventory.layer", options

        options = _.extend {onHovering:(itemDisplay)=> @onBlockHovered(itemDisplay)}, baseOptions
        @multiblockController = @addChild MultiblockController, ".view__multiblock", options

        @$backButton  = @$(".button.back")
        @$nextButton  = @$(".button.next")
        @$captionText = @$(".caption p")
        @$captionIcon = @$(".caption img")
        super

    onWillChangeModel: (oldModel, newModel)->
        if not newModel? then throw new Error "model is required"
        if newModel.constructor isnt RecipeDisplay then throw new Error "model must be a RecipeDisplay"
        return super oldModel, newModel

    refresh: ->
        @completeInventoryController.model = @model.getInventory()
        @layerInventoryController.model = @model.getInventory @multiblockController.currentLayer
        @multiblockController.model = @model

        if @multiblockController.hasBackLayer()
            @$backButton.removeClass "disabled"
        else
            @$backButton.addClass "disabled"

        if @multiblockController.hasNextLayer()
            @$nextButton.removeClass "disabled"
        else
            @$nextButton.addClass "disabled"

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            "click .button.back": "onBackClicked"
            "click .button.next": "onNextClicked"
