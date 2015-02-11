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

        @have   = new Inventory
        @want   = new Inventory
        @need   = new Inventory
        @result = new Inventory

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
        @have.localizeTo @modPack
        @want.localizeTo @modPack

        @result.addInventory @have

        @steps = {}
        @_reservedSteps = {}
        @want.each (stack)=>
            @_findSteps stack.slug
            item = @modPack.findItem stack.slug
            @need.add item.qualifiedSlug, stack.quantity
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
            item = @modPack.findItem stack.slug
            if not item? then toRemove.push stack.slug

        for slug in toRemove
            @want.remove slug

    # Event Methods ################################################################################

    onIncludingToolsChanged: ->
        @storage.setItem 'includingTools', "#{@includingTools}"
        @craft()

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

    _addStep: (recipe)->
        logger.verbose -> "adding step: #{recipe.item.qualifiedSlug}"
        @steps[recipe.item.qualifiedSlug] = recipe:recipe

    _chooseRecipe: (item)->
        return item.getPrimaryRecipe()

    _findSteps: (slug)->
        item = @modPack.findItem slug
        return unless item?
        return unless item.isCraftable
        return if item.isGatherable

        recipe = @_chooseRecipe item

        if @includingTools
            for toolStack in recipe.tools
                if not @_hasStep toolStack.slug
                    @_findSteps toolStack.slug

        return if @_hasStep item.qualifiedSlug
        @_reservedSteps[item.qualifiedSlug] = recipe

        for inputStack in recipe.input
            @_findSteps inputStack.slug

        @_addStep recipe

    _hasStep: (slug)->
        return true if @steps[slug]?
        return true if @_reservedSteps[slug]?
        return false

    _qualifyItemSlug: (slug)->
        item = @modPack.findItem slug
        return item.qualifiedSlug if item?
        return slug

    _removeExtraSteps: ->
        result = (step for step in @steps when step.multiplier > 0)
        @steps = result

    _resolveNeeds: ->
        for i in [@steps.length-1..0] by -1
            step   = @steps[i]
            recipe = step.recipe

            step.multiplier = Math.ceil(@need.quantityOf(recipe.slug) / recipe.output[0].quantity)

            if @includingTools
                for stack in recipe.tools
                    slug      = @_qualifyItemSlug stack.slug
                    available = @result.quantityOf(slug) + @need.quantityOf(slug)
                    needed    = Math.max 0, stack.quantity - available

                    @need.add slug, needed
                    @result.add slug, needed

            for stack in recipe.input
                slug      = @_qualifyItemSlug stack.slug
                needed    = step.multiplier * stack.quantity
                consumed  = Math.min needed, @result.quantityOf slug
                remaining = needed - consumed

                @result.remove slug, consumed
                @need.add slug, remaining

            for stack in recipe.output
                slug      = @_qualifyItemSlug stack.slug
                created   = stack.quantity * step.multiplier
                consumed  = Math.min created, @need.quantityOf slug
                remaining = created - consumed

                @result.add slug, remaining
                @need.remove slug, consumed
