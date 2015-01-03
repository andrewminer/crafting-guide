###
# Crafting Guide - crafting_plan.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

Inventory = require './inventory'

########################################################################################################################

module.exports = class CraftingPlan

    constructor: (@modPack, includingTools)->
        if not @modPack then throw new Error 'modPack is required'
        @includingTools = if includingTools then true else false
        @clear()

    # Public Methods ###############################################################################

    clear: ->
        @make       = new Inventory
        @need       = new Inventory
        @result     = new Inventory
        @steps      = []
        @_expected  = new Inventory
        @_pending   = null

        return this

    craft: (name, quantity=1, have=null)->
        logger.trace "craft(#{name}, #{quantity}, #{have})"

        item = @modPack.findItemByName name
        logger.debug "item: #{item}"
        if not item? then throw new Error "cannot find an item named: #{name}"

        @clear()
        @result.addInventory(have) if have?

        @_expected.add item, quantity
        @_pending = @_expected.clone()

        while not @_pending.isEmpty
            @_processPending()

        @steps.reverse()

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} { need:#{@need}, make:#{@make}, result:#{@result} }"

    # Private Methods ##############################################################################

    _processPending: ->
        targetStack = @_pending.pop()
        targetItem = targetStack.item
        logger.verbose "processing item: #{targetItem}, craftable? #{targetItem.isCraftable}"
        return unless targetItem?
        return if (not targetItem.isCraftable) or targetItem.isGatherable

        recipe = targetItem.recipes[0]
        logger.verbose "recipe: #{recipe}"

        if @includingTools
            for toolItem in recipe.tools
                totalExpected = @result.quantityOf(toolItem.slug) + @_expected.quantityOf(toolItem.slug)
                if totalExpected < 1
                    @_pending.add toolItem
                    @_expected.add toolItem

        while @_totalQuantityOf(targetItem.slug) < @_expected.quantityOf(targetItem.slug)
            @steps.push recipe

            for stack in recipe.input
                @_processInputStack stack

            for stack in recipe.output
                @_processOutputStack stack

    _processInputStack: (stack)->
        slug              = stack.item.slug
        quantityAvailable = @result.quantityOf slug
        quantityUsed      = Math.min quantityAvailable, stack.quantity
        quantityNeeded    = stack.quantity - quantityUsed
        logger.verbose "processing input:#{stack.name},
            a:#{quantityAvailable}, u:#{quantityUsed}, n:#{quantityNeeded}"

        @result.remove slug, quantityUsed
        @_pending.add stack.item, quantityNeeded
        @need.add stack.item, quantityNeeded

    _processOutputStack: (stack)->
        slug            = stack.item.slug
        quantityMissing = @need.quantityOf slug
        quantityUsed    = Math.min quantityMissing, stack.quantity
        quantityLeft    = stack.quantity - quantityUsed
        logger.verbose "processing output:#{stack.name},
            m:#{quantityMissing}, u:#{quantityUsed}, l:#{quantityLeft}"

        @make.add stack.item, stack.quantity
        @need.remove slug, quantityUsed
        @result.add stack.item, quantityLeft

    _totalQuantityOf: (slug)->
        return @result.quantityOf(slug) - @need.quantityOf(slug)
