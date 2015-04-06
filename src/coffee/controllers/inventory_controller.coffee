###
Crafting Guide - inventory_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController         = require './base_controller'
ImageLoader            = require './image_loader'
ItemSelectorController = require './item_selector_controller'
NameFinder             = require '../models/name_finder'
StackController        = require './stack_controller'
{Duration}             = require '../constants'
{Event}                = require '../constants'
{Key}                  = require '../constants'

########################################################################################################################

module.exports = class InventoryController extends BaseController

    @MAX_QUANTITY = 9999

    @ONLY_DIGITS = /^[0-9]*$/

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        @editable     = options.editable     ?= true
        @icon         = options.icon         ?= '/images/chest_front.png'
        @imageLoader  = options.imageLoader
        @isAcceptable = options.isAcceptable ?= null
        @modPack      = options.modPack
        @onChange     = options.onChange     ?= -> # do nothing
        @title        = options.title        ?= 'Inventory'

        options.templateName  = 'inventory'
        super options

        @_stackControllers = []

        @listenTo @modPack, Event.change, => @refresh()

    # Event Methods ################################################################################

    onClearButtonClicked: ->
        @model.clear()
        @onChange()

    onItemChosen: (itemSlug)->
        @model.add itemSlug, 1
        @onChange()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @selector = @addChild ItemSelectorController, '.view__item_selector',
            isAcceptable: @isAcceptable
            modPack:      @modPack,
            onChoseItem:  (itemSlug)=> @onItemChosen(itemSlug)

        @$clearButton   = @$('button[name="clear"]')
        @$icon          = @$('.icon')
        @$editPanel     = @$('.edit')
        @$scrollbox     = @$('.scrollbox')
        @$table         = @$('table')
        @$toolbar       = @$('.toolbar')
        @$title         = @$('h2 p')
        super

    refresh: ->
        if @editable
            @show @$editPanel
            @show @$toolbar, =>
                @$scrollbox.css bottom:@$toolbar.height()
        else
            if not @$editPanel? then throw new Error "no edit panel"
            if not @$toolbar? then throw new Error "no toolbar"
            @hide @$editPanel
            @hide @$toolbar
            @$scrollbox.css bottom:0

        @$icon.attr 'src', @icon
        @$title.html @title

        @_refreshStacks()
        @_refreshButtonState()

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click button[name="clear"]': 'onClearButtonClicked'

    # Private Methods ##############################################################################

    _refreshButtonState: ->
        if @model.isEmpty then @$clearButton.attr('disabled', 'disabled') else @$clearButton.removeAttr('disabled')

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
                    onChange:    @onChange
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
