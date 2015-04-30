###
Crafting Guide - crafting_table_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController          = require './base_controller'
ImageLoader             = require './image_loader'
MinimalRecipeController = require './minimal_recipe_controller'
_                       = require 'underscore'
{Duration}              = require '../constants'
{Event}                 = require '../constants'

########################################################################################################################

module.exports = class CraftingTableController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'crafting_table'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack

    # Event Methods ################################################################################

    onNextClicked: ->
        @model.stepIndex += 1

    onPrevClicked: ->
        @model.stepIndex -= 1

    onReportProblem: ->
        itemList = @model.plan.want.unparse()
        toolsMessage = if @model.plan.includingTools then '(including tools)' else ''
        message  = "When I was on step #{@model.stepIndex + 1} of making:
            \n\n#{itemList}#{toolsMessage}\n\nI noticed that...\n"
        global.feedbackController.enterFeedback message

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @recipeController = @addChild MinimalRecipeController, '.view__minimal_recipe',
            imageLoader: @imageLoader
            modPack:     @modPack

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
            @$problemControl.addClass 'hidden'
        else
            @$problemControl.removeClass 'hidden'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .next':      'onNextClicked'
            'click .prev':      'onPrevClicked'
            'click .problem a': 'onReportProblem'
