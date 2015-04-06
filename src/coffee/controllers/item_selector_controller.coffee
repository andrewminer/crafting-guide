###
Crafting Guide - item_selector_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController                = require './base_controller'
ItemSelector                  = require '../models/item_selector'
ItemSelectorElementController = require './item_selector_element_controller'
{Duration}                    = require '../constants'
{Event}                       = require '../constants'
{Key}                         = require '../constants'

########################################################################################################################

module.exports = class ItemSelectorController extends BaseController

    constructor: (options)->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.model        ?= new ItemSelector {}, modPack:options.modPack
        options.onChoseItem  ?= (item)-> # do nothing
        options.templateName  = 'item_selector'
        super options

        @modPack     = options.modPack
        @onChoseItem = options.onChoseItem

        @_elementControllers = []

    # Event Methods ################################################################################

    onHintKeyPress: (event)->
        switch event.which
            when Key.Escape
                @_close()
                return false
            when Key.Enter
                @_chooseSelected()
                return false
            when Key.DownArrow
                @_selectNext()
                return false
            when Key.UpArrow
                @_selectPrevious()
                return false

    onHintChanged: (event)->
        @model.hint = @$hintField.val()
        @tryRefresh()
        @onResultSelected @_elementControllers[0]

    onLaunchButtonClicked: (event)->
        event.preventDefault()
        @model.hint = ''
        @refresh()

        $('body').addClass 'stop-scrolling'

        @$screen.append @$popup
        @$screen.css 'display', 'block'

        @$popup.offset @$el.offset()
        @$popup.css 'width', @$el.css 'width'
        @$popup.off Event.click
        @$popup.on Event.click, (event)=> @onPopupClicked(event)
        @$popup.removeClass 'hiding'

        @$hintField.on 'keyup', (event)=> @onHintKeyPress(event)
        @$hintField.on 'input', (event)=> @onHintChanged(event)

        @$popup.off Event.transitionEnd
        @$popup.one Event.transitionEnd, => @onPopupDisplayed()
        @$screen.one Event.click, (event)=> @onScreenClicked(event)

    onPopupClicked: (event)->
        return false

    onPopupDisplayed: ->
        @$hintField.focus()

    onResultClicked: (controller)->
        @_close()
        @onChoseItem controller.model.slug

    onResultSelected: (controller)->
        for c in @_elementControllers
            c.selected = false

        if controller?
            controller.selected = true

    onScreenClicked: (event)->
        @_close()
        return false

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$screen           = $('.view__screen') # find the shared, global screen
        @$popup            = @$('.view__item_selector_popup')
        @$hintField        = @$('.view__item_selector_popup input')
        @$searchInput      = @$('.search input')
        @$resultsContainer = @$('.results')

        @$popup.detach()
        super

    refresh: ->
        @$hintField.val @model.hint
        @_refreshResults()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click': 'onLaunchButtonClicked'

    # Private Methods ##############################################################################

    _chooseSelected: ->
        for controller in @_elementControllers
            if controller.selected
                @onResultClicked controller
                return

    _close: ->
        $('body').removeClass 'stop-scrolling'

        @$popup.addClass 'hiding'

        @$popup.off Event.transitionEnd
        @$popup.one Event.transitionEnd, =>
            @$screen.css 'display', 'none'
            @$popup.detach()

    _refreshResults: ->
        index = 0

        for itemSlug in @model.results
            displayModel = @modPack.findItemDisplay itemSlug
            controller = @_elementControllers[index]
            if not controller?
                controller = new ItemSelectorElementController
                    model:      displayModel
                    onClicked:  (c)=> @onResultClicked(c)
                    onSelected: (c)=> @onResultSelected(c)
                controller.render show:false
                @_elementControllers[index] = controller
                @$resultsContainer.append controller.$el
            else
                controller.model = displayModel

            controller.show()
            index += 1

        while @_elementControllers.length > index
            @_elementControllers.pop().remove()

    _selectNext: ->
        for i in [0...(@_elementControllers.length - 1)] by 1
            controller = @_elementControllers[i]
            nextController = @_elementControllers[i + 1]

            if controller.selected
                controller.selected = false
                nextController.selected = true
                @_showElement nextController.$el
                return

    _selectPrevious: ->
        for i in [1...@_elementControllers.length] by 1
            previousController = @_elementControllers[i - 1]
            controller = @_elementControllers[i]

            if controller.selected
                previousController.selected = true
                controller.selected = false
                @_showElement previousController.$el
                return

    _showElement: ($el)->
        top = $el.position().top + @$resultsContainer.scrollTop()
        @$resultsContainer.animate {scrollTop:top}, duration:Duration.snap
