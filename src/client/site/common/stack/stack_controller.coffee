#
# Crafting Guide - stack_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'

########################################################################################################################

###
Events:
    change(this)
    change:quantity(this, oldQuantity, newQuantity)
    button:first(this, type)
    button:second(this, type)
###
module.exports = class StackController extends BaseController

    @::MAX_QUANTITY = 9999

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'

        options.templateName  = 'common/stack'
        super options

        @_editable           = options.editable           ?= false
        @_firstButtonType    = options.firstButtonType    ?= null
        @_imageLoader        = options.imageLoader
        @_modPack            = options.modPack
        @_secondButtonType   = options.secondButtonType   ?= null
        @_shouldEnableButton = options.shouldEnableButton ?= (model, button)-> true

        @_modPack.on c.event.change, => @tryRefresh()

    # Event Methods ################################################################################

    onFirstButtonClicked: (event)->
        @trigger c.event.button.first, this, @_firstButtonType
        return false

    onQuantityFieldBlur: ->
        return unless @_editable

        oldQuantity = @_priorValue
        quantityText = @$quantityField.val().trim()
        if quantityText.length is 0
            newQuantity = oldQuantity
        else if not quantityText.match /^[0-9]*$/
            newQuantity = 1
        else
            newQuantity = parseInt quantityText, 10
            if _.isNaN newQuantity then newQuantity = 1

            newQuantity = Math.min newQuantity, @MAX_QUANTITY
            newQuantity = Math.max 1, newQuantity

        @$quantityField.val "#{newQuantity}"
        if newQuantity? and newQuantity isnt oldQuantity
            @$quantityField.removeClass 'error'
            @$quantityField.removeClass 'error-new'

            @model.quantity = newQuantity
            @trigger c.event.change + ':quantity', this, oldQuantity, newQuantity
            @trigger c.event.change, this

    onQuantityFieldChanged: ->
        return unless @_editable

        quantityText = @$quantityField.val().trim()
        if not quantityText.match /^[0-9]*$/
            @$quantityField.addClass 'error', 0
            @$quantityField.addClass 'error-new', 0
            @$quantityField.removeClass 'error-new'
        else
            @$quantityField.removeClass 'error'
            @$quantityField.removeClass 'error-new'

    onQuantityFieldFocused: ->
        if @_editable
            @$quantityField.addClass 'editing'
            @_priorValue = @model.quantity
            @$quantityField.val ''
        else
            @$quantityField.blur()

    onQuantityKeyUp: (event)->
        return unless @_editable

        if event.which is c.key.return
            @$quantityField.blur()

    onSecondButtonClicked: (event)->
        event.preventDefault()
        @trigger c.event.button.second, this, @_secondButtonType

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$firstAction   = @$('.action.first')
        @$firstButton   = @$('.action.first .button')
        @$image         = @$('.icon img')
        @$nameLink      = @$('.name a')
        @$quantityField = @$('.quantity input')
        @$secondAction  = @$('.action.second')
        @$secondButton  = @$('.action.second .button')
        super

    refresh: ->
        if not @model? then throw new Error "must have a model to render"

        display = @_modPack.findItemDisplay @model.itemSlug

        @_imageLoader.load display.iconUrl, @$image
        @$nameLink.html display.itemName
        @$nameLink.attr 'href', display.itemUrl

        quantityText = if @model.quantity > 10000 then "#{@model.quantity / 1000}k" else "#{@model.quantity}"
        @$quantityField.val quantityText

        @_refreshButtons()

        if @_editable
            @$el.addClass 'editable'
            @$quantityField.css 'width', ''
            @$quantityField.removeAttr 'readonly'
        else
            @$el.removeClass 'editable'
            @$quantityField.css 'width', "#{quantityText}".length * 0.66 + "em"
            @$quantityField.attr 'readonly', 'readonly'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'blur .quantity input':         'onQuantityFieldBlur'
            'click .name a':                'routeLinkClick'
            'click .action.first .button':  'onFirstButtonClicked'
            'click .action.second .button': 'onSecondButtonClicked'
            'focus .quantity input':        'onQuantityFieldFocused'
            'input .quantity input':        'onQuantityFieldChanged'
            'keyup .quantity input':        'onQuantityKeyUp'

    # Private Methods ##############################################################################

    _refreshButtons: ->
        @_updateButtonType @$firstButton, @_firstButtonType
        @_updateButtonType @$secondButton, @_secondButtonType

        actions = [@$firstAction, @$secondAction]
        buttons = [@$firstButton, @$secondButton]

        for buttonType, index in [@_firstButtonType, @_secondButtonType]
            display = if @_shouldEnableButton(@model, index) then '' else 'none'
            display = if not buttonType? then 'none' else display
            actions[index].css 'display', display

            $label = buttons[index].find 'p'
            switch buttonType
                when 'check' then $label.text '✓'
                when 'down' then $label.text '⬇︎'
                when 'remove' then $label.text '-'
                when 'up' then $label.text '⬆︎'

    _updateButtonType: ($button, type)->
        for currentType in ['check', 'down', 'remove', 'up']
            $button.removeClass currentType

        if type?
            $button.css 'display', null
            $button.addClass type
        else
            $button.css 'display', 'none'
