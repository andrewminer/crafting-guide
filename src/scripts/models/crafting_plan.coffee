###
Crafting Guide - crafting_plan.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Event}   = require '../constants'
Inventory = require './inventory'

########################################################################################################################

module.exports = class CraftingPlan extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.modPack then throw new Error 'modPack is required'
        attributes.includingTools ?= false
        super attributes, options

        @have   = new Inventory modPack:@modPack
        @want   = new Inventory modPack:@modPack
        @need   = new Inventory modPack:@modPack
        @result = new Inventory modPack:@modPack

        recraft = _.debounce (=> @craft()), 100
        for inventory in [@have, @want]
            inventory.on 'change', recraft

        @on Event.change + ':includingTools', recraft

        @clear()

    # Public Methods ###############################################################################

    clear: (options={})->
        @steps = []
        @need.clear()
        @result.clear()

        @trigger 'change', this
        return this

    craft: ->
        toolsMessage = if @includingTools then ' (including tools)' else ''
        logger.info => "crafting #{@want}#{toolsMessage} starting with #{@have}"

        @clear()
        @have.localize()
        @want.localize()

        @result.addInventory @have

        @steps = {}
        @_reservedSteps = {}
        @want.each (stack)=>
            @_findSteps stack.itemSlug
            item = @modPack.findItem stack.itemSlug
            @need.add item.slug, stack.quantity
        @_reservedSteps = null

        @steps = _.values @steps
        @_resolveNeeds()
        @_removeExtraSteps()

        @result.addInventory @want

        @need.trigger 'change', @need
        @result.trigger 'change', @result
        @trigger 'change', this

    removeUncraftableItems: ->
        toRemove = []
        @want.each (stack)=>
            item = @modPack.findItem stack.itemSlug
            if not item? then toRemove.push stack.itemSlug

        for itemSlug in toRemove
            @want.remove itemSlug

    # Event Methods ################################################################################

    onIncludingToolsChanged: ->
        @storage.setItem 'includingTools', "#{@includingTools}"
        @craft()

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} {
                have:#{@have},
                want:#{@want},
                need:#{@need},
                result:#{@result},
                steps:#{@steps}
            }"

    # Private Methods ##############################################################################

    _addStep: (recipe)->
        logger.verbose -> "adding step: #{recipe.itemSlug}"
        @steps[recipe.itemSlug] = recipe:recipe

    _chooseRecipe: (item)->
        recipes = @modPack.findRecipes item.slug
        return null unless recipes?
        return recipes[0]

    _findSteps: (itemSlug)->
        item = @modPack.findItem itemSlug
        return unless item?
        return unless item.isCraftable
        return if item.isGatherable

        recipe = @_chooseRecipe item

        if @includingTools
            for toolStack in recipe.tools
                if not @_hasStep toolStack.itemSlug
                    @_findSteps toolStack.itemSlug

        return if @_hasStep item.slug
        @_reservedSteps[item.slug] = recipe

        for inputStack in recipe.input
            @_findSteps inputStack.itemSlug

        @_addStep recipe

    _hasStep: (itemSlug)->
        return true if @steps[itemSlug]?
        return true if @_reservedSteps[itemSlug]?
        return false

    _qualifyItemSlug: (itemSlug)->
        item = @modPack.findItem itemSlug
        return item.slug if item?
        return itemSlug

    _removeExtraSteps: ->
        result = (step for step in @steps when step.multiplier > 0)
        @steps = result

    _resolveNeeds: ->
        for i in [@steps.length-1..0] by -1
            step   = @steps[i]
            recipe = step.recipe

            step.multiplier = Math.ceil(@need.quantityOf(recipe.itemSlug) / recipe.output[0].quantity)

            if @includingTools
                for stack in recipe.tools
                    itemSlug  = @_qualifyItemSlug stack.itemSlug
                    available = @result.quantityOf(itemSlug) + @need.quantityOf(itemSlug)
                    needed    = Math.max 0, stack.quantity - available

                    @need.add itemSlug, needed
                    @result.add itemSlug, needed

            for stack in recipe.input
                itemSlug  = @_qualifyItemSlug stack.itemSlug
                needed    = step.multiplier * stack.quantity
                consumed  = Math.min needed, @result.quantityOf itemSlug
                remaining = needed - consumed

                @result.remove itemSlug, consumed
                @need.add itemSlug, remaining

            for stack in recipe.output
                itemSlug  = @_qualifyItemSlug stack.itemSlug
                created   = stack.quantity * step.multiplier
                consumed  = Math.min created, @need.quantityOf itemSlug
                remaining = created - consumed

                @result.add itemSlug, remaining
                @need.remove itemSlug, consumed
