###
Crafting Guide - crafting_table_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController         = require './base_controller'
CraftingGridController = require './crafting_grid_controller'
{Duration}             = require '../constants'
ImageLoader            = require './image_loader'

########################################################################################################################

module.exports = class CraftingTableController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.imageLoader ?= new ImageLoader default:'/images/unknown.png'
        options.templateName = 'crafting_table'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack

    # Event Methods ################################################################################

    onNextClicked: ->
        @model.step += 1

    onPrevClicked: ->
        @model.step -= 1

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @gridController = @addChild CraftingGridController, '.view__crafting_grid', model:@model.grid

        @$multiplier     = @$('.multiplier')
        @$next           = @$('.next')
        @$outputImg      = @$('.output img')
        @$outputLink     = @$('.output a')
        @$outputQuantity = @$('.quantity')
        @$prev           = @$('.prev')
        @$title          = @$('h2 p')
        @$tool           = @$('.tool p')

        @defaultTitle = @$title.html()
        super

    refresh: ->
        @$prev.removeClass 'enabled'
        @$next.removeClass 'enabled'

        if @model.hasSteps
            if @model.hasPrevStep then @$prev.addClass 'enabled'
            if @model.hasNextStep then @$next.addClass 'enabled'
            @$title.html "Step #{@model.step + 1} of #{@model.stepCount}"
        else
            @$title.html @defaultTitle

        @$tool.html @model.toolNames

        @$outputImg.attr 'src', '/images/empty.png'
        @$outputImg.removeAttr 'alt'
        @$outputLink.removeAttr 'href'
        @$outputQuantity.html ''

        outputStack = @model.output
        if outputStack?
            display = @modPack.findItemDisplay outputStack.itemSlug
            @$outputLink.attr 'href', display.itemUrl
            @$outputLink.attr 'title', display.itemName
            @$outputImg.attr 'alt', display.itemName
            @$outputQuantity.html outputStack.quantity if outputStack.quantity > 1

            @imageLoader.load display.iconUrl, @$outputImg

        if @model.multiplier > 1
            @$multiplier.html "×#{@model.multiplier}"
        else
            @$multiplier.html ''

        @$el.tooltip show:{delay:Duration.slow, duration:Duration.fast}
        super

    # Backbone.View Overrides ######################################################################

    events:
        'click .next': 'onNextClicked'
        'click .prev': 'onPrevClicked'
