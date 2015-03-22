###
Crafting Guide - inventory_table_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController  = require './base_controller'
{Duration}      = require '../constants'
ImageLoader     = require './image_loader'
ItemSlug        = require '../models/item_slug'
{Key}           = require '../constants'
NameFinder      = require '../models/name_finder'
StackController = require './stack_controller'

########################################################################################################################

module.exports = class InventoryTableController extends BaseController

    @ONLY_DIGITS = /^[0-9]*$/

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        @editable    = options.editable    ?= true
        @imageLoader = options.imageLoader
        @modPack     = options.modPack
        @nameFinder  = options.nameFinder  ?= new NameFinder options.modPack
        @onChange    = options.onChange    ?= -> # do nothing

        options.templateName  = 'inventory_table'
        super options

        @_stackControllers = []

        @listenTo @modPack, 'change', => @tryRefresh()

    # Event Methods ################################################################################

    onAddButtonClicked: ->
        name = @modpack.findItemByName @$nameField.val()
        return unless item?

        @model.add item.slug, parseInt(@$quantityField.val())
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
        @_refreshButtonState()

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
        @_refreshButtonState()

    onQuantityFieldFocused: ->
        @$quantityField.val ''

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$addButton     = @$('button[name="add"]')
        @$clearButton   = @$('button[name="clear"]')
        @$editPanel     = @$('.edit')
        @$nameField     = @$('input[name="name"]')
        @$quantityField = @$('input[name="quantity"]')
        @$scrollbox     = @$('.scrollbox')
        @$table         = @$('table')
        @$toolbar       = @$('.toolbar')
        super

    refresh: ->
        if @editable
            @show @$editPanel
            @show @$toolbar, =>
                @$scrollbox.css bottom:@$toolbar.height()
        else
            @hide @$editPanel
            @hide @$toolbar
            @$scrollbox.css bottom:0

        if _.isEmpty(@$quantityField.val()) then @$quantityField.val '1'

        @_refreshNameAutocomplete()
        @_refreshButtonState()
        @_refreshStacks()

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

    _refreshButtonState: ->
        if @model.isEmpty then @$clearButton.attr('disabled', 'disabled') else @$clearButton.removeAttr('disabled')

        itemValid     = @modPack.findItemByName(@$nameField.val())?
        quantityValid = @$quantityField.val().match(InventoryTableController.ONLY_DIGITS)
        disable       = not (itemValid and quantityValid)
        if disable then @$addButton.attr('disabled', 'disabled') else @$addButton.removeAttr('disabled')

    _refreshNameAutocomplete: ->
        onChanged = => @onNameFieldChanged()
        onSelected = => @onItemSelected()

        @$nameField.autocomplete
            source:    (request, callback)=> callback @nameFinder.search request.term
            delay:     0
            minLength: 0
            change:    onChanged
            close:     onChanged
            select:    onSelected

    _refreshStacks: ->
        @_stackControllers ?= []
        index = 0

        $lastRow = @$table.find 'tr:last-child'
        @model.each (stack)=>
            controller = @_stackControllers[index]
            if not controller?
                controller = new StackController
                    editable:    @editable
                    imageLoader: @imageLoader
                    model:       stack
                    modPack:     @modPack
                    onRemove:    if not @editable then null else (stack)=> @_removeStack(stack)

                @_stackControllers.push controller
                controller.$el.insertBefore $lastRow
                controller.render()
            else
                controller.model = stack

            index += 1

        while @_stackControllers.length > index
            @_stackControllers.pop().remove()

    _removeStack: (stack)->
        @model.remove stack.itemSlug, stack.quantity
