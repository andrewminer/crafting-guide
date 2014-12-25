###
# Crafting Guide - crafting_table_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseController = require './base_controller'
InventoryParser = require '../models/inventory_parser'

########################################################################################################################

module.exports = class CraftingTableController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'crafting_table'
        super options

        @_parser = new InventoryParser

    # Event Methods ################################################################################

    onHaveFieldChanged: ->
        return unless @rendered

        @model.have.clear()
        @_parser.parse @$haveField.val(), @model.have
        @model.craft()

    onIncludingToolsFieldChanged: ->
        return unless @rendered
        @model.includingTools = @$('input[name="including_tools"]:checked').length > 0
        @model.craft()

    onNameFieldChanged: ->
        return unless @rendered
        @model.name = @$nameField.val()
        @model.craft()

    onQuantityFieldChanged: ->
        return unless @rendered
        @model.quantity = parseInt @$quantityField.find(":selected").val()
        @model.craft()

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

        @onHaveFieldChanged()
        @onIncludingToolsFieldChanged()
        @onQuantityFieldChanged()

        # do last so others are no-op until all is set
        @onNameFieldChanged()

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
        'input input[name="name"]': 'onNameFieldChanged'
        'input select[name="quantity"]': 'onQuantityFieldChanged'
        'change input[name="including_tools"]': 'onIncludingToolsFieldChanged'
