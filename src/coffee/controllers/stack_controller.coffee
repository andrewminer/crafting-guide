###
Crafting Guide - stack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
ImageLoader    = require './image_loader'
_              = require 'underscore'
{Duration}     = require '../constants'
{Event}        = require '../constants'
{Key}          = require '../constants'

########################################################################################################################

###
Events:
    change(this)
    change:quantity(this, oldQuantity, newQuantity)
    button:first(this, type)
    button:second(this, type)
###
module.exports = class StackController extends BaseController

    @MAX_QUANTITY = 9999

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        options.templateName  = 'stack'
        super options

        @editable           = options.editable           ?= false
        @firstButtonType    = options.firstButtonType    ?= null
        @imageLoader        = options.imageLoader
        @modPack            = options.modPack
        @secondButtonType   = options.secondButtonType   ?= null
        @shouldEnableButton = options.shouldEnableButton ?= (model, button)-> true

        @modPack.on Event.change, => @tryRefresh()

    # Event Methods ################################################################################

    onFirstButtonClicked: (event)->
        @trigger Event.button.first, this, @firstButtonType
        return false

    onQuantityFieldBlur: ->
        return unless @editable

        @$bubble.removeClass 'editing'

        oldQuantity = @_priorValue
        quantityText = @$quantityField.val().trim()
        if quantityText.length is 0
            newQuantity = oldQuantity
        else if not quantityText.match /^[0-9]*$/
            newQuantity = 1
        else
            newQuantity = parseInt quantityText, 10
            if _.isNaN newQuantity then newQuantity = 1

            newQuantity = Math.min newQuantity, StackController.MAX_QUANTITY
            newQuantity = Math.max 1, newQuantity

        @$quantityField.val "#{newQuantity}"
        if newQuantity? and newQuantity isnt oldQuantity
            @$bubble.removeClass 'error', Duration.snap
            @$bubble.removeClass 'error-new', Duration.snap

            @model.quantity = newQuantity
            @trigger Event.change + ':quantity', this, oldQuantity, newQuantity
            @trigger Event.change, this

    onQuantityFieldChanged: ->
        return unless @editable

        quantityText = @$quantityField.val().trim()
        if not quantityText.match /^[0-9]*$/
            @$bubble.addClass 'error', 0
            @$bubble.addClass 'error-new', 0
            @$bubble.removeClass 'error-new', Duration.fast
        else
            @$bubble.removeClass 'error', Duration.snap
            @$bubble.removeClass 'error-new', Duration.snap

    onQuantityFieldFocused: ->

        if @editable
            @$bubble.addClass 'editing'
            @_priorValue = @model.quantity
            @$quantityField.val ''
        else
            @$quantityField.blur()

    onQuantityKeyUp: (event)->
        return unless @editable

        if event.which is Key.Return
            @$quantityField.blur()

    onSecondButtonClicked: (event)->
        event.preventDefault()
        @trigger Event.button.second, this, @secondButtonType

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$action        = @$('.action')
        @$bubble        = @$('.bubble')
        @$firstButton   = @$('button.first')
        @$image         = @$('.icon img')
        @$nameLink      = @$('.name a')
        @$quantityField = @$('.quantity input')
        @$secondButton  = @$('button.second')
        super

    refresh: ->
        if not @model? then throw new Error "must have a model to render"

        display = @modPack.findItemDisplay @model.itemSlug

        @imageLoader.load display.iconUrl, @$image
        @$nameLink.html display.itemName
        @$nameLink.attr 'href', display.itemUrl
        @$quantityField.val @model.quantity

        @_updateButtonType @$firstButton, @firstButtonType
        @_updateButtonType @$secondButton, @secondButtonType

        @$firstButton.prop('disabled', not @shouldEnableButton(@model, 1)) if @firstButtonType?
        @$secondButton.prop('disabled', not @shouldEnableButton(@model, 2)) if @secondButtonType?

        if @editable
            @$quantityField.removeAttr 'readonly'
            @$bubble.addClass 'editable'
        else
            @$quantityField.attr 'readonly', 'readonly'
            @$bubble.removeClass 'editable'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'blur .quantity input':  'onQuantityFieldBlur'
            'click .name a':         'routeLinkClick'
            'click button.first':    'onFirstButtonClicked'
            'click button.second':   'onSecondButtonClicked'
            'focus .quantity input': 'onQuantityFieldFocused'
            'input .quantity input': 'onQuantityFieldChanged'
            'keyup .quantity input': 'onQuantityKeyUp'

    # Private Methods ##############################################################################

    _updateButtonType: ($button, type)->
        for currentType in ['check', 'down', 'remove', 'up']
            $button.removeClass currentType

        if type?
            $button.css 'display', null
            $button.addClass type
        else
            $button.css 'display', 'none'
