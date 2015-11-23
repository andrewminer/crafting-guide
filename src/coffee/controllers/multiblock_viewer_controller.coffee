###
Crafting Guide - multiblock_viewer_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

_                    = require '../underscore_mixins'
BaseController       = require './base_controller'
MultiblockController = require './multiblock_controller'

########################################################################################################################

module.exports = class MultiblockViewerController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'multiblock_viewer'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack

    # Event Methods ################################################################################

    onBackClicked: ->
        return if @backButton.hasClass 'disabled'
        @multiblockController.goBackLayer()
        @refresh()

    onNextClicked: ->
        return if @nextButton.hasClass 'disabled'
        @multiblockController.goNextLayer()
        @refresh()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @multiblockController = @addChild MultiblockController, '.view__multiblock',
            imageLoader: @_imageLoader
            modPack:     @_modPack

        @backButton = @$('.button.back')
        @nextButton = @$('.button.next')
        super

    refresh: ->
        @multiblockController.model = @model

        if @multiblockController.hasBackLayer()
            @backButton.removeClass 'disabled'
        else
            @backButton.addClass 'disabled'

        if @multiblockController.hasNextLayer()
            @nextButton.removeClass 'disabled'
        else
            @nextButton.addClass 'disabled'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            'click .button.back': 'onBackClicked'
            'click .button.next': 'onNextClicked'
