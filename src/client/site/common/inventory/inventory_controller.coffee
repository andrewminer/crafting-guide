#
# Crafting Guide - inventory_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController         = require '../../base_controller'
ItemSelectorController = require '../item_selector/item_selector_controller'
StackController        = require '../stack/stack_controller'

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
        if not options.router? then throw new Error 'options.router is required'

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

        @_editable           = options.editable           ?= true
        @_icon               = options.icon               ?= '/images/chest_front.png'
        @_firstButtonType    = options.firstButtonType    ?= null
        @_isAcceptable       = options.isAcceptable       ?= null
        @_secondButtonType   = options.secondButtonType   ?= null
        @_shouldEnableButton = options.shouldEnableButton ?= (model, button)-> true

        options.templateName  = 'common/inventory'
        super options

        @_stackControllers = []

        @listenTo @_modPack, c.event.change, => @tryRefresh()

    # Event Methods ################################################################################

    onClearButtonClicked: ->
        return unless @model?
        return if @$clearButton.hasClass 'disabled'

        @model.clear()
        @trigger c.event.clear, this
        @trigger c.event.change, this

    onFirstButtonClicked: (stackController)->
        @trigger c.event.button.first, this, stackController?.model?.itemSlug

    onItemSelectorButtonClicked: ->
        return unless @model?

        @_selector.launch()
            .then (itemSlug)=>
                return unless itemSlug?

                @model.add itemSlug, 1
                @trigger c.event.add, this, itemSlug
                @trigger c.event.change, this

    onSecondButtonClicked: (stackController)->
        @trigger c.event.button.second, this, stackController?.model?.itemSlug

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_selector = @addChild ItemSelectorController, null, isAcceptable: @_isAcceptable, modPack: @_modPack

        @$clearButton      = @$('.button.clear')
        @$emptyPlaceholder = @$('.empty_placeholder')
        @$icon             = @$('.icon')
        @$itemContainer    = @$('.item_container')
        @$title            = @$('h2 p')
        super

    refresh: ->
        if @_editable
            @_selector.show()
            @show @$clearButton
        else
            @_selector.hide()
            @hide @$clearButton

        @$icon.attr 'src', @_icon

        @_refreshStacks()

        if not @model or @model.isEmpty
            @show @$emptyPlaceholder
            @$clearButton.addClass 'disabled'
        else
            @hide @$emptyPlaceholder
            @$clearButton.removeClass 'disabled'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .button.item-selector': 'onItemSelectorButtonClicked'
            'click .button.clear':         'onClearButtonClicked'
            'click button.first':          'onFirstButtonClicked'
            'click button.second':         'onSecondButtonClicked'

    # Private Methods ##############################################################################

    _refreshStacks: ->
        @_stackControllers ?= []
        index = 0

        if @model?
            @model.each (stack)=>
                controller = @_stackControllers[index]
                if not controller?
                    controller = new StackController
                        editable:           @_editable
                        firstButtonType:    @_firstButtonType
                        imageLoader:        @_imageLoader
                        model:              stack
                        modPack:            @_modPack
                        router:             @_router
                        secondButtonType:   @_secondButtonType
                        shouldEnableButton: @_shouldEnableButton
                    controller.on c.event.change, => @trigger c.event.change, this
                    controller.on c.event.button.first, (c)=> @onFirstButtonClicked(c)
                    controller.on c.event.button.second, (c)=> @onSecondButtonClicked(c)
                    controller.render()

                    @_stackControllers.push controller
                    @$itemContainer.append controller.$el
                else
                    controller.model = stack
                index += 1

        while @_stackControllers.length > index
            @_stackControllers.pop().remove()
