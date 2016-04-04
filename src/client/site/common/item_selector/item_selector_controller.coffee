#
# Crafting Guide - item_selector_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController    = require '../../base_controller'
ItemSelector      = require '../../../models/site/item_selector'
ElementController = require './element/element_controller'

########################################################################################################################

module.exports = class ItemSelectorController extends BaseController

    constructor: (options)->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.isAcceptable ?= null
        options.model        ?= new ItemSelector {}, modPack:options.modPack, isAcceptable:options.isAcceptable
        options.onChoseItem  ?= (item)-> # do nothing
        options.templateName  = 'common/item_selector'
        super options

        @_modPack = options.modPack
        @_session = null

        @_elementControllers = []

    # Public Methods ###############################################################################

    launch: (hint='')->
        if @_session
            @_session.resolve null
            @_session = null

        @model.hint = hint
        if @rendered then @refresh()

        @_disableWindowScrolling()

        @$page.addClass 'blur'
        @$screen.append @$popup
        @$screen.css 'display', ''

        @$popup.off c.event.click
        @$popup.on c.event.click, (event)=> @onPopupClicked(event)

        @$hintField.off 'keyup input'
        @$hintField.on 'keyup', (event)=> @onHintKeyPress(event)
        @$hintField.on 'input', (event)=> @onHintChanged(event)
        @$hintField.focus()

        @$closeButton.one 'click', (event)=> @_close()

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
            when c.key.down
                @_selectNext()
                return false
            when c.key.up
                @_selectPrevious()
                return false

    onHintChanged: (event)->
        @model.hint = @$hintField.val()
        @tryRefresh()
        @onResultSelected @_elementControllers[0]

    onPopupClicked: (event)->
        return false

    onResultClicked: (controller)->
        @_session.resolve controller.model.slug
        @_session = null
        @_close()

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
        @$page             = $('.page') # find the shared, global page
        @$screen           = $('.view__screen') # find the shared, global screen

        @$closeButton      = @$('img.close')
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

    # Private Methods ##############################################################################

    _chooseSelected: ->
        for controller in @_elementControllers
            if controller.selected
                @onResultClicked controller
                return

    _close: ->
        @_enableWindowScrolling()
        @$page.removeClass 'blur'
        @$screen.css 'display', 'none'
        @$popup.detach()
        @model.hint = ''

    _disableWindowScrolling: ->
        @_windowScrollPosition = $(window).scrollTop()
        $('body').addClass('scrollDisabled').css('margin-top', -@_windowScrollPosition)

    _enableWindowScrolling: ->
        $('body').removeClass('scrollDisabled').css('margin-top', 0)
        $(window).scrollTop @_windowScrollPosition

    _refreshResults: ->
        index = 0

        for itemSlug in @model.results
            displayModel = @_modPack.findItemDisplay itemSlug
            controller = @_elementControllers[index]
            if not controller?
                controller = new ElementController
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
        @$resultsContainer.css 'scrollTop', top
