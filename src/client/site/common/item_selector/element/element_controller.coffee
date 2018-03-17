#
# Crafting Guide - element.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../../base_controller'

########################################################################################################################

module.exports = class ElementController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.onClicked ?= (controller)-> # do nothing
        options.onSelected ?= (controller)-> # do nothing
        options.templateName = 'common/item_selector/element'
        options.useAnimations = false
        super options

        @onClicked = options.onClicked
        @onSelected = options.onSelected

    # Property Methods #############################################################################

    isSelected: ->
        return @_selected

    setSelected: (newSelected)->
        oldSelected = @_selected
        return if newSelected is oldSelected

        @_selected = newSelected
        @tryRefresh()

        @trigger c.event.change + ':selected', this, oldSelected, newSelected
        @trigger c.event.change, this

    Object.defineProperties @prototype,
        selected: {get:@prototype.isSelected, set:@prototype.setSelected}

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$icon = @$('img')
        @$name = @$('.name')
        @$modName = @$('.modName')
        super

    refresh: ->
        @$icon.attr 'src', @model.iconUrl
        @$name.html @model.itemName
        @$modName.html @model.modName

        if @_selected
            @$el.addClass 'selected'
        else
            @$el.removeClass 'selected'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click': '_onClick'
            'mouseenter': '_onMouseEnter'

    # Private Methods ##############################################################################

    _onClick: (event)->
        event.preventDefault()
        @onClicked this

    _onMouseEnter: (event)->
        event.preventDefault()
        @onSelected this
