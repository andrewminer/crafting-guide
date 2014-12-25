###
# Crafting Guide - crafting_plan.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

Inventory = require './inventory'

########################################################################################################################

module.exports = class CraftingPlan

    constructor: (@catalog, includingTools)->
        if not @catalog then throw new Error 'catalog is required'
        @includingTools = if includingTools then true else false
        @clear()

    # Public Methods ###############################################################################

    clear: ->
        @make      = new Inventory
        @need      = new Inventory
        @result    = new Inventory
        @steps     = []
        @_expected = new Inventory
        @_pending  = null

        return this

    craft: (name, quantity=1, have=null)->
        @clear()
        @result.addInventory(have) if have?

        @_expected.add name, quantity
        @_pending = @_expected.clone()
        while not @_pending.isEmpty
            @_processPending()

        @steps.reverse()

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} { need:#{@need}, make:#{@make}, result:#{@result} }"

    # Private Methods ##############################################################################

    _processPending: ->
        targetItem = @_pending.pop()
        return unless targetItem?

        recipes = @catalog.findRecipes targetItem.name
        return if not recipes.length > 0
        recipe = recipes[0]

        if @includingTools
            for tool in recipe.tools
                totalExpected = @result.quantityOf(tool.name) + @_expected.quantityOf(tool.name)
                if totalExpected < tool.quantity
                    @_pending.add tool.name, tool.quantity
                    @_expected.add tool.name, tool.quantity

        while @_totalQuantityOf(targetItem.name) < @_expected.quantityOf(targetItem.name)
            @steps.push recipe

            for item in recipe.input
                @_processInputItem item

            for item in recipe.output
                @_processOutputItem item

    _processInputItem: (item)->
        quantityAvailable = @result.quantityOf item.name
        quantityUsed      = Math.min quantityAvailable, item.quantity
        quantityNeeded    = item.quantity - quantityUsed

        @result.remove item.name, quantityUsed
        @_pending.add item.name, quantityNeeded
        @need.add item.name, quantityNeeded

    _processOutputItem: (item)->
        quantityMissing = @need.quantityOf item.name
        quantityUsed = Math.min quantityMissing, item.quantity
        quantityLeft = item.quantity - quantityUsed

        @need.remove item.name, quantityUsed
        @result.add item.name, quantityLeft
        @make.add item.name, item.quantity

    _totalQuantityOf: (name)->
        return @result.quantityOf(name) - @need.quantityOf(name)
