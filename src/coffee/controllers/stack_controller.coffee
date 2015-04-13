###
Crafting Guide - stack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Duration}     = require '../constants'
{Event}        = require '../constants'
ImageLoader    = require './image_loader'
{Key}          = require '../constants'

########################################################################################################################

module.exports = class StackController extends BaseController

    @MAX_QUANTITY = 9999

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        options.editable     ?= false
        options.onChange     ?= -> # do nothing
        options.onRemove     ?= (stack)-> # do nothing
        options.tagName       = 'tr'
        options.templateName  = 'stack'
        super options

        @editable     = options.editable
        @modPack      = options.modPack
        @onChange     = options.onChange
        @onRemove     = options.onRemove
        @_imageLoader = options.imageLoader

        @modPack.on Event.change, => @tryRefresh()

    # Event Methods ################################################################################

    onQuantityFieldBlur: ->
        return unless @editable

        quantityText = @$quantityField.val().trim()
        if quantityText.length is 0
            quantity = @_priorValue
        else if not quantityText.match /^[0-9]*$/
            quantity = 1
        else
            quantity = parseInt quantityText, 10
            if _.isNaN quantity then quantity = 1

            quantity = Math.min quantity, StackController.MAX_QUANTITY
            quantity = Math.max 1, quantity

        if quantity?
            @$quantityField.val "#{quantity}"
            @$quantityField.removeClass 'error', Duration.snap
            @$quantityField.removeClass 'error-new', Duration.snap

            @model.quantity = quantity
            @onChange()

    onQuantityFieldChanged: ->
        return unless @editable

        quantityText = @$quantityField.val().trim()
        if not quantityText.match /^[0-9]*$/
            @$quantityField.addClass 'error', 0
            @$quantityField.addClass 'error-new', 0
            @$quantityField.removeClass 'error-new', Duration.fast
        else
            @$quantityField.removeClass 'error', Duration.snap
            @$quantityField.removeClass 'error-new', Duration.snap

    onQuantityFieldFocused: ->
        if @editable
            @_priorValue = @model.quantity
            @$quantityField.val ''
        else
            @$quantityField.blur()

    onQuantityKeyUp: (event)->
        return unless @editable

        if event.which is Key.Return
            @$quantityField.blur()

    onRemoveClicked: ->
        @onRemove @model
        @onChange()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$action        = @$('.action')
        @$image         = @$('.icon img')
        @$nameLink      = @$('.name a')
        @$quantityField = @$('.quantity input')
        @$removeButton  = @$('button.remove')
        super

    refresh: ->
        if not @model? then throw new Error "must have a model to render"

        display = @modPack.findItemDisplay @model.itemSlug

        @_imageLoader.load display.iconUrl, @$image
        @$nameLink.html display.itemName
        @$nameLink.attr 'href', display.itemUrl
        @$quantityField.val @model.quantity

        if @editable
            @$quantityField.removeAttr 'readonly'
            @$quantityField.addClass 'editable'
        else
            @$quantityField.attr 'readonly', 'readonly'
            @$quantityField.removeClass 'editable'

        @$action.css display:(if @editable then 'table-cell' else 'none')

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'blur .quantity input':  'onQuantityFieldBlur'
            'click button.remove':   'onRemoveClicked'
            'click .name a':         'routeLinkClick'
            'focus .quantity input': 'onQuantityFieldFocused'
            'input .quantity input': 'onQuantityFieldChanged'
            'keyup .quantity input': 'onQuantityKeyUp'
