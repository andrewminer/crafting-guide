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

        @_parser         = new InventoryParser
        @_name           = null
        @_quantity       = null
        @_includingTools = null

    # Event Methods ################################################################################

    onHaveFieldChanged: ->
        return unless @rendered

        @model.have.clear()
        @_parser.parse @$haveField.val(), @model.have
        @_recalculate()

    onIncludingToolsFieldChanged: ->
        return unless @rendered
        @_includingTools = @$('input[name="including_tools"]:checked').length > 0
        @_recalculate()

    onNameFieldChanged: ->
        return unless @rendered
        @_name = @$nameField.val()
        @_recalculate()

    onQuantityFieldChanged: ->
        return unless @rendered
        @_quantity = parseInt @$quantityField.find(":selected").val()
        @_recalculate()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$haveField           = @$('textarea[name="have"]')
        @$includingToolsField = @$('input[name="including_tools"]')
        @$nameField           = @$('input[name="name"]')
        @$quantityField       = @$('select[name="quantity"]')

        super

        @onHaveFieldChanged()
        @onIncludingToolsFieldChanged()
        @onNameFieldChanged()
        @onQuantityFieldChanged()

    # Backbone.View Overrides ######################################################################

    events:
        'input textarea[name="have"]': 'onHaveFieldChanged'
        'input input[name="name"]': 'onNameFieldChanged'
        'input select[name="quantity"]': 'onQuantityFieldChanged'
        'change input[name="including_tools"]': 'onIncludingToolsFieldChanged'

    # Private Methods ##############################################################################

    _recalculate: ->
        return if not @_name? or @_name.length is 0
        @model.craft @_name, @_quantity
