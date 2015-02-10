###
Crafting Guide - inventory_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController  = require './base_controller'
{Duration}      = require '../constants'
{Key}           = require '../constants'
ImageLoader     = require './image_loader'
NameFinder      = require '../models/name_finder'
StackController = require './stack_controller'

########################################################################################################################

module.exports = class InventoryController extends BaseController

    @ONLY_DIGITS = /^[0-9]*$/

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        @editable    = options.editable    ?= true
        @icon        = options.icon        ?= '/images/chest_front.png'
        @imageLoader = options.imageLoader ?= new ImageLoader defaultUrl:'/images/unknown.png'
        @modPack     = options.modPack
        @nameFinder  = options.nameFinder  ?= new NameFinder options.modPack
        @onChange    = options.onChange    ?= -> # do nothing
        @title       = options.title       ?= 'Inventory'

        options.templateName  = 'inventory'
        super options

        @_stackControllers = []

        @listenTo @modPack, 'change', => @refresh()

    # Event Methods ################################################################################

    onAddButtonClicked: ->
        name = @$nameField.val()
        return unless @modPack.isValidName name

        @model.add _.slugify(name), parseInt(@$quantityField.val())
        @$nameField.val ''
        @$quantityField.val '1'

        @$scrollbox.scrollTop @$scrollbox.prop 'scrollHeight'
        @$nameField.autocomplete 'close'

        @onChange()

    onClearButtonClicked: ->
        @model.clear()
        @onChange()

    onItemSelected: ->
        func = =>
            @onNameFieldChanged()
            @onAddButtonClicked()
            @$nameField.blur()

        setTimeout func, 10 # needed to allow the autocomplete to finish
        return true

    onNameFieldBlur: ->
        item = @modPack.findItemByName @$nameField.val()
        @$nameField.val if item? then item.name else ''
        @onNameFieldChanged()

    onNameFieldChanged: ->
        item = @modPack.findItemByName @$nameField.val()
        @_updateButtonState()

    onNameFieldFocused: ->
        @$nameField.val ''
        @$nameField.autocomplete('search')

    onNameFieldKeyUp: (event)->
        if event.which is Key.Return
            @onAddButtonClicked()

    onQuantityFieldBlur: ->
        value = @$quantityField.val().replace /[^0-9]/g, ''
        if value.length is 0 then value = '1'
        value = Math.min value, 64
        @$quantityField.val value
        @onQuantityFieldChanged()

    onQuantityFieldChanged: ->
        if not @$quantityField.val().match /^[0-9]*$/
            @$quantityField.addClass 'error', 0
            @$quantityField.addClass 'error-new', 0
            @$quantityField.removeClass 'error-new', Duration.slow
            @$quantityField.focus()
            return

        @$quantityField.removeClass 'error', Duration.normal
        @$quantityField.removeClass 'error-new', Duration.normal
        @_updateButtonState()

    onQuantityFieldFocused: ->
        @$quantityField.val ''

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$addButton     = @$('button[name="add"]')
        @$clearButton   = @$('button[name="clear"]')
        @$icon          = @$('.icon')
        @$editPanel     = @$('.edit')
        @$nameField     = @$('input[name="name"]')
        @$quantityField = @$('input[name="quantity"]')
        @$scrollbox     = @$('.scrollbox')
        @$table         = @$('table')
        @$toolbar       = @$('.toolbar')
        @$title         = @$('h2 p')
        super

    refresh: ->
        @$editPanel.css display:(if @editable then 'table-row' else 'none')
        @$toolbar.css display:(if @editable then 'block' else 'none')
        @$scrollbox.css bottom:(if @editable then @$toolbar.height() else '0')

        @$icon.attr 'src', @icon
        @$title.html @title

        if _.isEmpty(@$quantityField.val()) then @$quantityField.val '1'

        @$table.find('tr:not(:last-child)').remove()
        $lastRow = @$table.find 'tr:last-child'
        @_stackControllers = []
        @model.each (stack)=>
            options =
                editable:    @editable
                imageLoader: @imageLoader
                model:       stack
                modPack:     @modPack
                onRemove:    if not @editable then null else (stack)=> @_removeStack(stack)

            controller = new StackController options
            controller.render()
            controller.$el.insertBefore $lastRow
            @_stackControllers.push controller

        @_updateNameAutocomplete()
        @_updateButtonState()

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'blur input[name="name"]':      'onNameFieldBlur'
            'blur input[name="quantity"]':  'onQuantityFieldBlur'
            'click button[name="add"]':     'onAddButtonClicked'
            'click button[name="clear"]':   'onClearButtonClicked'
            'focus input[name="name"]':     'onNameFieldFocused'
            'focus input[name="quantity"]': 'onQuantityFieldFocused'
            'input input[name="name"]':     'onNameFieldChanged'
            'input input[name="quantity"]': 'onQuantityFieldChanged'
            'keyup input[name="name"]':     'onNameFieldKeyUp'

    # Private Methods ##############################################################################

    _removeStack: (stack)->
        @model.remove stack.slug, stack.quantity

    _updateNameAutocomplete: ->
        onChanged = => @onNameFieldChanged()
        onSelected = => @onItemSelected()

        @$nameField.autocomplete
            source:    (request, callback)=> callback @nameFinder.search request.term
            delay:     0
            minLength: 0
            change:    onChanged
            close:     onChanged
            select:    onSelected

    _updateButtonState: ->
        if @model.isEmpty then @$clearButton.attr('disabled', 'disabled') else @$clearButton.removeAttr('disabled')

        itemValid     = @modPack.findItemByName(@$nameField.val())?
        quantityValid = @$quantityField.val().match(InventoryController.ONLY_DIGITS)
        disable       = not (itemValid and quantityValid)
        if disable then @$addButton.attr('disabled', 'disabled') else @$addButton.removeAttr('disabled')
