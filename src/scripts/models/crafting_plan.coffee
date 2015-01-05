###
Crafting Guide - crafting_plan.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
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
        if not item? then throw new Error "cannot find an item named: #{name}"

        @clear()
        @result.addInventory(have) if have?

        @_expected.add item.slug, quantity
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
        targetItem = @modPack.findItem targetStack.itemSlug
        logger.verbose "processing item: #{targetStack}"
        return unless targetItem?
        return if (not targetItem.isCraftable) or targetItem.isGatherable

        recipe = targetItem.recipes[0]
        logger.verbose "recipe: #{recipe}"

        if @includingTools
            for toolStack in recipe.tools
                slug = toolStack.itemSlug
                totalExpected = @result.quantityOf(slug) + @_expected.quantityOf(slug)
                if totalExpected < 1
                    @_pending.add slug
                    @_expected.add slug

        while @_totalQuantityOf(targetItem.slug) < @_expected.quantityOf(targetItem.slug)
            @steps.push recipe

            for stack in recipe.input
                @_processInputStack stack

            for stack in recipe.output
                @_processOutputStack stack

    _processInputStack: (stack)->
        quantityAvailable = @result.quantityOf stack.itemSlug
        quantityUsed      = Math.min quantityAvailable, stack.quantity
        quantityNeeded    = stack.quantity - quantityUsed
        logger.trace "processing input:#{stack.itemSlug},
            a:#{quantityAvailable}, u:#{quantityUsed}, n:#{quantityNeeded}"

        @result.remove stack.itemSlug, quantityUsed
        @_pending.add stack.itemSlug, quantityNeeded
        @need.add stack.itemSlug, quantityNeeded

    _processOutputStack: (stack)->
        quantityMissing = @need.quantityOf stack.itemSlug
        quantityUsed    = Math.min quantityMissing, stack.quantity
        quantityLeft    = stack.quantity - quantityUsed
        logger.trace "processing output:#{stack.itemSlug},
            m:#{quantityMissing}, u:#{quantityUsed}, l:#{quantityLeft}"

        @make.add stack.itemSlug, stack.quantity
        @need.remove stack.itemSlug, quantityUsed
        @result.add stack.itemSlug, quantityLeft

    _totalQuantityOf: (itemSlug)->
        return @result.quantityOf(itemSlug) - @need.quantityOf(itemSlug)
