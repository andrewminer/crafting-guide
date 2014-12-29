###
# Crafting Guide - crafting_table_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseController  = require './base_controller'
{Event}         = require '../constants'
InventoryParser = require '../models/inventory_parser'
url             = require 'url'
{UrlParam}      = require '../constants'

########################################################################################################################

module.exports = class CraftingTableController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'crafting_table'
        super options

        @_parser = new InventoryParser

        @model.catalog.on Event.change, => @onCatalogChanged()

    # Event Methods ################################################################################

    onCatalogChanged: ->
        return unless @rendered
        @_updateNameAutocomplete()
        @_craft()

    onHaveFieldChanged: ->
        return unless @rendered

        @model.have.clear()
        @_parser.parse @$haveField.val(), @model.have
        @_craft()

    onIncludingToolsFieldChanged: ->
        return unless @rendered
        @model.includingTools = @$('input[name="including_tools"]:checked').length > 0
        @_craft()

    onNameFieldChanged: ->
        return unless @rendered
        @model.name = @$nameField.val()
        @_craft()

    onNameFieldFocused: ->
        return unless @rendered
        @$nameField.autocomplete 'search'

    onQuantityFieldChanged: ->
        return unless @rendered
        @model.quantity = parseInt @$quantityField.find(":selected").val()
        @_craft()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$haveField           = @$('textarea[name="have"]')
        @$includingToolsField = @$('input[name="including_tools"]')
        @$nameField           = @$('input[name="name"]')
        @$quantityField       = @$('select[name="quantity"]')

        @$needList   = @$('td.need ul')
        @$makeList   = @$('td.make ul')
        @$resultList = @$('td.result ul')

        @_updateNameAutocomplete()
        @_craft()

        super

    refresh: ->
        @$nameField.val @model.name
        @$quantityField.val @model.quantity
        if @model.includingTools
            @$includingToolsField.attr 'checked', 'checked'
        else
            @$includingToolsField.removeAttr 'checked'

        @$needList.empty()
        @$makeList.empty()
        @$resultList.empty()

        if @model.plan?
            @model.plan.need.each (item)=>
                @$needList.append "<li><span class='quantity'>#{item.quantity}</span> #{item.name}</li>"
            @model.plan.make.each (item)=>
                @$makeList.append "<li><span class='quantity'>#{item.quantity}</span> #{item.name}</li>"
            @model.plan.result.each (item)=>
                @$resultList.append "<li><span class='quantity'>#{item.quantity}</span> #{item.name}</li>"

        super

    # Backbone.View Overrides ######################################################################

    events:
        'input textarea[name="have"]':          'onHaveFieldChanged'
        'focus input[name="name"]':             'onNameFieldFocused'
        'input input[name="name"]':             'onNameFieldChanged'
        'input select[name="quantity"]':        'onQuantityFieldChanged'
        'change input[name="including_tools"]': 'onIncludingToolsFieldChanged'

    # Private Methods ##############################################################################

    _craft: ->
        if @model.catalog.findRecipes(@model.name).length > 0
            router.navigate "/item/#{encodeURIComponent(@model.name)}"
            @model.craft()
        else
            router.navigate "/item"

    _updateNameAutocomplete: ->
        onChanged = => @onNameFieldChanged()

        @$nameField.autocomplete
            source:    @model.catalog.getRecipeNames()
            delay:     0
            minLength: 0
            change:    onChanged
            close:     onChanged
            select:    onChanged
