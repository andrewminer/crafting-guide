#
# Crafting Guide - multiblock_viewer_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController       = require "../../base_controller"
InventoryController  = require "../../common/inventory/inventory_controller"
MultiblockController = require "./multiblock/multiblock_controller"
MultiblockDisplay    = require "../../../models/site/multiblock_display"

########################################################################################################################

module.exports = class MultiblockViewerController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"
        options.templateName = "item_page/multiblock_viewer"
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
        @completeInventoryController = @addChild InventoryController, ".view__inventory.complete",
            editable:    false
            imageLoader: @_imageLoader
            modPack:     @_modPack
            router:      @_router

        @layerInventoryController = @addChild InventoryController, ".view__inventory.layer",
            editable:    false
            imageLoader: @_imageLoader
            modPack:     @_modPack
            router:      @_router

        @multiblockController = @addChild MultiblockController, ".view__multiblock",
            imageLoader: @_imageLoader
            modPack:     @_modPack
            onHovering:  (itemDisplay)=> @onBlockHovered(itemDisplay)

        @$backButton  = @$(".button.back")
        @$nextButton  = @$(".button.next")
        @$captionText = @$(".caption p")
        @$captionIcon = @$(".caption img")
        super

    onWillChangeModel: (oldModel, newModel)->
        @_display = new MultiblockDisplay newModel
        super oldModel, newModel

    refresh: ->
        if @model? and @_display?
            @completeInventoryController.model = @_display.getInventory()
            @layerInventoryController.model = @_display.getInventory @multiblockController.currentLayer
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
