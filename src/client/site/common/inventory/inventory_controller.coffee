#
# Crafting Guide - inventory_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
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
        @_trackingContext    = options.trackingContext    ?= null

        options.templateName  = 'common/inventory'
        super options

        @_stackControllers = []

    # Event Methods ################################################################################

    onClearButtonClicked: ->
        return unless @model?
        return if @$clearButton.hasClass 'disabled'

        tracker.trackEvent @_trackingContext, 'clear'
        @model.clear()
        @trigger c.event.clear, this
        @trigger c.event.change, this

    onFirstButtonClicked: (stackController)->
        item = stackController.model?.item
        tracker.trackEvent @_trackingContext, 'remove-from', item.id
        @trigger c.event.button.first, this, item

    onItemSelectorButtonClicked: ->
        return unless @model?

        tracker.trackEvent @_trackingContext, 'launch-add-to'
        @_selector.launch()
            .then (item)=>
                if not item?
                    tracker.trackEvent @_trackingContext, 'cancel-add-to'
                    return

                tracker.trackEvent @_trackingContext, 'complete-add-to', "#{item.id}"
                @model.add item, 1
                @trigger c.event.add, this, item.id
                @trigger c.event.change, this

    onSecondButtonClicked: (stackController)->
        itemId = stackController.model?.item.id
        @trigger c.event.button.second, this, stackController?.model?.itemSlug

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_selector = @addChild ItemSelectorController, null, isAcceptable:@_isAcceptable, modPack:@_modPack

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
            for itemId, stack of @model.stacks
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
                        trackingContext:    @_trackingContext
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

