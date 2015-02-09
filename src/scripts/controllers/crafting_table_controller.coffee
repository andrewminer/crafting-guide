###
Crafting Guide - crafting_table_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController   = require './base_controller'
{Duration}       = require '../constants'
ImageLoader      = require './image_loader'
InventoryParser  = require '../models/inventory_parser'
MinimalRecipeController = require './minimal_recipe_controller'

########################################################################################################################

module.exports = class CraftingTableController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.imageLoader ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.templateName = 'crafting_table'
        super options

        @_imageLoader = options.imageLoader
        @_modPack    = options.modPack

    # Event Methods ################################################################################

    onNextClicked: ->
        @model.stepIndex += 1

    onPrevClicked: ->
        @model.stepIndex -= 1

    onReportProblem: ->
        parser   = new InventoryParser @_modPack
        itemList = parser.unparse @model.plan.want
        toolsMessage = if @model.plan.includingTools then '(including tools)' else ''
        message  = "When I was on step #{@model.stepIndex + 1} of making:
            \n\n#{itemList}#{toolsMessage}\n\nI noticed that...\n"
        global.feedbackController.enterFeedback message

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @recipeController = @addChild MinimalRecipeController, '.view__minimal_recipe', imageLoader:@_imageLoader, modPack:@_modPack

        @$next           = @$('.next')
        @$prev           = @$('.prev')
        @$problemControl = @$('.problem')
        @$title          = @$('h2 p')
        @$tool           = @$('.tool p')

        @$multiplier = $('<p class="multiplier"></p>')
        @$('.output').append @$multiplier

        @defaultTitle = @$title.html()
        super

    refresh: ->
        @$prev.removeClass 'enabled'
        @$next.removeClass 'enabled'

        if @model.hasSteps
            if @model.hasPrevStep then @$prev.addClass 'enabled'
            if @model.hasNextStep then @$next.addClass 'enabled'
            @$title.html "Step #{@model.stepIndex + 1} of #{@model.stepCount}"
        else
            @$title.html @defaultTitle

        currentStep = @model.currentStep
        @recipeController.model = currentStep?.recipe

        if currentStep?.multiplier > 1
            @$multiplier.html "×#{currentStep.multiplier}"
        else
            @$multiplier.html ''

        if not (@model.hasSteps and global.feedbackController?)
            @$problemControl.hide duration:Duration.fast
        else
            @$problemControl.show duration:Duration.normal

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .next':      'onNextClicked'
            'click .prev':      'onPrevClicked'
            'click .problem a': 'onReportProblem'
