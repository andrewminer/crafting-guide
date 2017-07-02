#
# Crafting Guide - item_selector_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController    = require "../../base_controller"
ItemDisplay       = require "../../../models/site/item_display"
ItemSelector      = require "../../../models/site/item_selector"
ElementController = require "./element/element_controller"
w                 = require "when"

########################################################################################################################

module.exports = class ItemSelectorController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error "options.modPack is required"
        options.isAcceptable ?= null
        options.model        ?= new ItemSelector options.modPack, isAcceptable:options.isAcceptable
        options.onChoseItem  ?= (item)-> # do nothing
        options.templateName  = "common/item_selector"
        super options

        @_modPack = options.modPack
        @_session = null

        @_elementControllers = []

    # Public Methods ###############################################################################

    launch: (hint="")->
        @model.hint = hint
        if @rendered then @refresh()

        @_disableWindowScrolling()

        @$page.addClass "blur"
        @$screen.append @$popup
        @$screen.css "display", ""

        @$popup.off c.event.click
        @$popup.on c.event.click, (event)=> @onPopupClicked(event)

        @$hintField.off "keyup input"
        @$hintField.on "keyup", (event)=> @onHintKeyPress(event)
        @$hintField.on "input", (event)=> @onHintChanged(event)
        @$hintField.focus()

        @$closeButton.one "click", (event)=> @_close()

        @$screen.one c.event.click, (event)=> @onScreenClicked(event)

        @_session = w.defer()
        return @_session.promise

    # Event Methods ################################################################################

    onClose: (event)->
        @_close()
        return false

    onHintKeyPress: (event)->
        switch event.which
            when c.key.escape
                @_close()
                return false
            when c.key.enter
                @_chooseSelected()
                return false
            when c.key.downArrow
                @_selectNext()
                return false
            when c.key.upArrow
                @_selectPrevious()
                return false

    onHintChanged: (event)->
        @model.hint = @$hintField.val()
        @tryRefresh()
        @onResultSelected @_elementControllers[0]
        return false

    onPopupClicked: (event)->
        return false

    onResultClicked: (controller)->
        @_session.resolve controller.model
        @_session = null
        @_close()
        return false

    onResultSelected: (controller)->
        for c in @_elementControllers
            c.isSelected = false

        if controller?
            controller.isSelected = true

        return false

    onScreenClicked: (event)->
        @_close()
        return false

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$page             = $(".page") # find the shared, global page
        @$screen           = $(".view__screen") # find the shared, global screen

        @$closeButton      = @$("img.close")
        @$popup            = @$(".view__item_selector_popup")
        @$hintField        = @$(".view__item_selector_popup input")
        @$searchInput      = @$(".search input")
        @$resultsContainer = @$(".results")

        @$popup.detach()
        super

    refresh: ->
        @$hintField.val @model.hint
        @_refreshResults()
        super

    # Private Methods ##############################################################################

    _chooseSelected: ->
        for controller in @_elementControllers
            if controller.isSelected
                @onResultClicked controller
                return

    _close: ->
        @_enableWindowScrolling()
        @$page.removeClass "blur"
        @$screen.css "display", "none"
        @$popup.detach()
        @model.hint = ""

        if @_session
            @_session.resolve null
            @_session = null

    _disableWindowScrolling: ->
        @_windowScrollPosition = $(window).scrollTop()
        $("body").addClass("scrollDisabled").css("margin-top", -@_windowScrollPosition)

    _enableWindowScrolling: ->
        $("body").removeClass("scrollDisabled").css("margin-top", 0)
        $(window).scrollTop @_windowScrollPosition

    _refreshResults: ->
        index = 0

        for item in @model.results
            controller = @_elementControllers[index]
            if not controller?
                controller = new ElementController
                    model:      item
                    onClicked:  (c)=> @onResultClicked(c)
                    onSelected: (c)=> @onResultSelected(c)
                controller.render show:false
                @_elementControllers[index] = controller
                @$resultsContainer.append controller.$el
            else
                controller.model = item

            controller.show()
            index += 1

        while @_elementControllers.length > index
            @_elementControllers.pop().remove()

    _selectNext: ->
        return unless @_elementControllers.length > 0

        for i in [0...(@_elementControllers.length - 1)] by 1
            controller = @_elementControllers[i]
            nextController = @_elementControllers[i + 1]

            if controller.isSelected
                controller.isSelected = false
                nextController.isSelected = true
                @_showElement nextController.$el
                return

        [..., controller] = @_elementControllers
        controller.isSelected = false

        controller = @_elementControllers[0]
        controller.isSelected = true
        @_showElement controller.$el

    _selectPrevious: ->
        return unless @_elementControllers.length > 0

        for i in [1...@_elementControllers.length] by 1
            previousController = @_elementControllers[i - 1]
            controller = @_elementControllers[i]

            if controller.isSelected
                previousController.isSelected = true
                controller.isSelected = false
                @_showElement previousController.$el
                return

        controller = @_elementControllers[0]
        controller.isSelected = false

        [..., controller] = @_elementControllers
        controller.isSelected = true
        @_showElement controller.$el

    _showElement: ($el)->
        top = $el.position().top + @$resultsContainer.scrollTop()
        @$resultsContainer.animate {scrollTop:top}, c.duration.snap
