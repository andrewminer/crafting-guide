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
_                      = require 'underscore'
{Duration}             = require '../constants'
{Event}                = require '../constants'
{Key}                  = require '../constants'

########################################################################################################################

###
Events:
    clear(this)
    change(this)
    add(this, itemSlug)
    button:first(this, itemSlug)
    button:second(this, itemSlug)
###
module.exports = class InventoryController extends BaseController

    @MAX_QUANTITY = 9999

    @ONLY_DIGITS = /^[0-9]*$/

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        @imageLoader = options.imageLoader
        @modPack     = options.modPack

        @editable           = options.editable           ?= true
        @icon               = options.icon               ?= '/images/chest_front.png'
        @firstButtonType    = options.firstButtonType    ?= null
        @isAcceptable       = options.isAcceptable       ?= null
        @secondButtonType   = options.secondButtonType   ?= null
        @shouldEnableButton = options.shouldEnableButton ?= (model, button)-> true
        @title              = options.title              ?= 'Inventory'

        options.templateName  = 'inventory'
        super options

        @_stackControllers = []

        @listenTo @modPack, Event.change, => @refresh()

    # Event Methods ################################################################################

    onClearButtonClicked: ->
        return unless @model?

        @model.clear()
        @trigger Event.clear, this
        @trigger Event.change, this

    onFirstButtonClicked: (stackController)->
        @trigger Event.button.first, this, stackController?.model?.itemSlug

    onItemChosen: (itemSlug)->
        return unless @model?

        @model.add itemSlug, 1
        @trigger Event.add, this, itemSlug
        @trigger Event.change, this

    onSecondButtonClicked: (stackController)->
        @trigger Event.button.second, this, stackController?.model?.itemSlug

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @selector = @addChild ItemSelectorController, '.view__item_selector',
            isAcceptable: @isAcceptable
            modPack:      @modPack,
            onChoseItem:  (itemSlug)=> @onItemChosen(itemSlug)

        @$clearButton      = @$('button.clear')
        @$emptyPlaceholder = @$('.empty_placeholder')
        @$icon             = @$('.icon')
        @$itemContainer    = @$('.item_container')
        @$title            = @$('h2 p')
        super

    refresh: ->
        if @editable
            @selector.show()
        else
            @selector.hide()

        @$icon.attr 'src', @icon
        @$title.html @title

        @_refreshStacks()

        @$clearButton.disabled = @model?.isEmpty

        if not @model or @model.isEmpty
            @show @$emptyPlaceholder
        else
            @hide @$emptyPlaceholder

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click button.clear': 'onClearButtonClicked'
            'click button.first': 'onFirstButtonClicked'
            'click button.second': 'onSecondButtonClicked'

    # Private Methods ##############################################################################

    _refreshStacks: ->
        @_stackControllers ?= []
        index = 0

        if @model?
            @model.each (stack)=>
                controller = @_stackControllers[index]
                if not controller?
                    controller = new StackController
                        editable:           @editable
                        firstButtonType:    @firstButtonType
                        imageLoader:        @imageLoader
                        model:              stack
                        modPack:            @modPack
                        secondButtonType:   @secondButtonType
                        shouldEnableButton: @shouldEnableButton
                    controller.on Event.change, => @trigger Event.change, this
                    controller.on Event.button.first, (c)=> @onFirstButtonClicked(c)
                    controller.on Event.button.second, (c)=> @onSecondButtonClicked(c)
                    controller.render()

                    @_stackControllers.push controller
                    @$itemContainer.append controller.$el
                else
                    controller.model = stack
                index += 1

        while @_stackControllers.length > index
            @_stackControllers.pop().remove()
