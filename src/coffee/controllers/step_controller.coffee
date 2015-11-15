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

        @canAddTools = options.canAddTools or (controller)-> true
        @canComplete = options.canComplete or (controller)-> true
        @onComplete  = options.onComplete or (controller)-> # do nothing
        @onAddTools  = options.onAddTools or (controller)-> # do nothing
        @imageLoader = options.imageLoader
        @modPack     = options.modPack

    # Event Methods ################################################################################

    onCompleteButtonClicked: (event)->
        return if @$completeButton.hasClass 'disabled'
        @onComplete this

    onToolButtonClicked: (event)->
        return if @$toolButton.hasClass 'disabled'
        @onAddTools this

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

        @$completeButton  = @$('.button.complete')
        @$header          = @$('h3')
        @$toolButton      = @$('.button.tool')
        @$toolButtonLabel = @$('.button.tool p')
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

        @_refreshCompleteButton()
        @_refreshToolButton()

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .button.complete': 'onCompleteButtonClicked'
            'click .button.tool':     'onToolButtonClicked'

    # Private Methods ##############################################################################

    _refreshToolButton: ->
        if @canAddTools this
            @$toolButton.removeClass 'disabled'
        else
            @$toolButton.addClass 'disabled'

    _refreshCompleteButton: ->
        if @canComplete this
            @$completeButton.removeClass 'disabled'
        else
            @$completeButton.addClass 'disabled'
