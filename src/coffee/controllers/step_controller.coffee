###
Crafting Guide - step_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_                       = require 'underscore'
BaseController          = require './base_controller'
{Event}                 = require '../constants'
InventoryController     = require './inventory_controller'
MinimalRecipeController = require './minimal_recipe_controller'

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

    onCompleteClicked: (event)->
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

        @$header        = @$('h3')
        @$completePanel = @$('.complete')
        @$completeImage = @$('.complete img')
        super

    onWillChangeModel: (oldModel, newModel)->
        if not newModel? then throw new Error 'model cannot be null'
        return super

    refresh: ->
        itemDisplay = @modPack.findItemDisplay @model.recipe.output[0].itemSlug
        @$header.html "#{@model.number}. #{itemDisplay.itemName}"

        @inventoryController.model   = @model.inventory
        @recipeController.model      = @model.recipe
        @recipeController.multiplier = @model.multiplier

        if @canComplete(this)
            @$completePanel.addClass 'disabled'
        else
            @$completePanel.removeClass 'disabled'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .complete a': 'onCompleteClicked'
