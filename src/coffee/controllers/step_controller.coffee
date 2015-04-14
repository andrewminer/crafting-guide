###
Crafting Guide - step_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController          = require './base_controller'
InventoryController     = require './inventory_controller'
MinimalRecipeController = require './minimal_recipe_controller'
{Event}                 = require '../constants'

########################################################################################################################

module.exports = class StepController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        options.templateName = 'step'
        super options

        @canComplete = options.canComplete or (controller)-> true
        @imageLoader = options.imageLoader
        @modPack     = options.modPack

    # Event Methods ################################################################################

    onCompleteButtonClicked: (event)->
        event.preventDefault()
        @trigger Event.button.complete, this

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @inventoryController = @addChild InventoryController, '.view__inventory',
            editable:    false
            imageLoader: @imageLoader
            model:       @model.inventory
            modPack:     @modPack

        @recipeController = @addChild MinimalRecipeController, '.view__minimal_recipe',
            imageLoader: @imageLoader
            model:       @model.recipe
            modPack:     @modPack

        @$header         = @$('h3')
        @$completeButton = @$('button.complete')
        super

    onWillChangeModel: (oldModel, newModel)->
        if not newModel? then throw new Error 'model cannot be null'
        return super

    refresh: ->
        itemDisplay = @modPack.findItemDisplay @model.outputItemSlug
        @$header.html "#{@model.number}. #{itemDisplay.itemName}"

        @inventoryController.model   = @model.inventory
        @recipeController.model      = @model.recipe
        @recipeController.multiplier = @model.multiplier

        if @canComplete(this)
            @$completeButton.removeProp 'disabled'
        else
            @$completeButton.prop 'disabled', true

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click button.complete': 'onCompleteButtonClicked'
