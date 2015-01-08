###
Crafting Guide - crafting_table_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
CraftingGridController = require './crafting_grid_controller'

########################################################################################################################

module.exports = class CraftingTableController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'crafting_table'
        super options

    # Event Methods ################################################################################

    onNextClicked: ->
        @model.step += 1

    onPrevClicked: ->
        @model.step -= 1

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, '.view__crafting_grid', model:@model.grid

        @$next = @$('.next')
        @$prev = @$('.prev')
        @$tool = @$('.tool p')
        super

    refresh: ->
        @$prev.removeClass 'enabled'
        @$next.removeClass 'enabled'

        if @model.hasSteps
            if @model.hasPrevStep then @$prev.addClass 'enabled'
            if @model.hasNextStep then @$next.addClass 'enabled'

        @$tool.html @model.toolNames

        super

    # Backbone.View Overrides ######################################################################

    events:
        'click .next': 'onNextClicked'
        'click .prev': 'onPrevClicked'
