#
# Crafting Guide - element.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController = require "../../../base_controller"
ItemDisplay    = require "../../../../models/site/item_display"

########################################################################################################################

module.exports = class ElementController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error "options.model is required"
        options.templateName = "common/item_selector/element"
        options.useAnimations = false
        super options

        @onClicked = options.onClicked or (controller)-> # do nothing
        @onSelected = options.onSelected or (controller)-> # do nothing

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        display:
            get: -> return @_display ?= new ItemDisplay @model
            set: -> throw new Error "display cannot be assigned"

        isSelected:
            get: -> return @_selected
            set: (newSelected)->
                oldSelected = @_selected
                return if newSelected is oldSelected

                @_selected = newSelected
                @tryRefresh()

                @trigger c.event.change + ":selected", this, oldSelected, newSelected
                @trigger c.event.change, this

    # BaseController Overrides #####################################################################

    onDidModelChange: ->
        @_display = null
        super

    onDidRender: ->
        @$icon = @$("img")
        @$name = @$(".name")
        @$modName = @$(".modName")
        super

    refresh: ->
        @$icon.attr "src", @display.iconUrl
        @$name.html @model.displayName
        @$modName.html @model.mod.displayName

        if @_selected
            @$el.addClass "selected"
        else
            @$el.removeClass "selected"

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            "click": "_onClick"
            "mouseenter": "_onMouseEnter"

    # Private Methods ##############################################################################

    _onClick: (event)->
        @onClicked this
        return false

    _onMouseEnter: (event)->
        @onSelected this
        return false
