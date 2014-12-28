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
        @_parseUrlParameters()

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

        super

        @_updateNameAutocomplete()
        @_parseUrlParameters()

    refresh: ->
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
        'input textarea[name="have"]': 'onHaveFieldChanged'
        'focus input[name="name"]': 'onNameFieldFocused'
        'input input[name="name"]': 'onNameFieldChanged'
        'input select[name="quantity"]': 'onQuantityFieldChanged'
        'change input[name="including_tools"]': 'onIncludingToolsFieldChanged'

    # Private Methods ##############################################################################

    _craft: ->
        @model.craft()

    _parseUrlParameters: ->
        params = url.parse(window.location.href, true).query

        if params[UrlParam.includingTools]?
            param = params[UrlParam.includingTools]
            if param in ['true', 'yes']
                @$includingToolsField.attr 'checked', 'checked'
            else if param in ['false', 'no']
                @$includingToolsField.removeAttr 'checked'
            else
                console.log "invalid including tools value in URL param: #{params[UrlParam.includingTools]}"
        @onIncludingToolsFieldChanged()

        if params[UrlParam.quantity]?
            @$quantityField.val parseInt params[UrlParam.quantity]
            if @$quantityField.find(':selected').length is 0
                console.log "invalid quantity in URL param: #{params[UrlParam.quantity]}"
        @onQuantityFieldChanged()

        # Do this check last to avoid recalculting the recipe multiple times
        if params[UrlParam.recipe]?
            recipeName = params[UrlParam.recipe]
            if @model.catalog.findRecipes(recipeName).length > 0
                @$nameField.val recipeName
            else
                console.log "invalid recipe name in URL param: #{params[UrlParam.recipe]}"
        @onNameFieldChanged()

    _updateNameAutocomplete: ->
        onChanged = => @onNameFieldChanged()

        @$nameField.autocomplete
            source:    @model.catalog.getRecipeNames()
            delay:     0
            minLength: 0
            change:    onChanged
            close:     onChanged
            select:    onChanged
