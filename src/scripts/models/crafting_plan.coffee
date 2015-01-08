###
Crafting Guide - crafting_plan.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
Inventory = require './inventory'

########################################################################################################################

module.exports = class CraftingPlan extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.modPack then throw new Error 'modPack is required'
        attributes.includingTools ?= false
        super attributes, options

        @have   = new Inventory
        @want   = new Inventory
        @need   = new Inventory
        @result = new Inventory

        @have.on 'change', => @craft()
        @want.on 'change', => @craft()

        @clear()

    # Public Methods ###############################################################################

    clear: ->
        @steps     = []
        @_expected = new Inventory
        @_pending  = null

        @need.clear()
        @result.clear()

        @trigger 'change', this
        return this

    craft: ->
        logger.trace "starting crafting plan for: #{@want} starting with #{@have}"
        @clear()
        return if @want.isEmpty

        @want.each (stack)=>
            @_expected = @want.clone()
            @_pending = @want.clone()

        @result.addInventory @have

        @_need = new Inventory
        while not @_pending.isEmpty
            @_processPending()

        @need.addInventory @_need
        @steps.reverse()

        @trigger 'change', this

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} {
                have:#{@have},
                want:#{@want},
                need:#{@_need},
                result:#{@result},
                steps:#{@steps}
            }"

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
        @_need.add stack.itemSlug, quantityNeeded

    _processOutputStack: (stack)->
        quantityMissing = @_need.quantityOf stack.itemSlug
        quantityUsed    = Math.min quantityMissing, stack.quantity
        quantityLeft    = stack.quantity - quantityUsed
        logger.trace "processing output:#{stack.itemSlug},
            m:#{quantityMissing}, u:#{quantityUsed}, l:#{quantityLeft}"

        @_need.remove stack.itemSlug, quantityUsed
        @result.add stack.itemSlug, quantityLeft

    _totalQuantityOf: (itemSlug)->
        return @result.quantityOf(itemSlug) - @_need.quantityOf(itemSlug)
