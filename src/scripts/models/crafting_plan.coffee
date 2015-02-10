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

        @clear()

        @have.on    Event.change, => @craft()
        @want.on    Event.change, => @craft()
        @modPack.on Event.change, => @craft()

        @on Event.change + ':includingTools', => @craft()

    # Public Methods ###############################################################################

    clear: (options={})->
        @steps = []
        @need.clear()
        @result.clear()

        @trigger 'change', this
        return this

    craft: ->
        @clear()

        @result.addInventory @have

        @steps = {}
        @_reservedSteps = {}
        @want.each (stack)=>
            @_findSteps stack.slug
            @need.add stack.slug, stack.quantity
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
        logger.verbose "adding step: #{recipe.slug}"
        @steps[recipe.slug] = recipe:recipe

    _chooseRecipe: (item)->
        return item.getPrimaryRecipe()

    _findSteps: (slug)->
        logger.debug "finding steps for #{slug}"
        item = @modPack.findItem slug
        return unless item?
        return unless item.isCraftable
        return if item.isGatherable

        recipe = @_chooseRecipe item

        if @includingTools
            for toolStack in recipe.tools
                if not @_hasStep toolStack.slug
                    @_findSteps toolStack.slug

        return if @_hasStep item.slug
        logger.debug "reserving: #{item.slug}"
        @_reservedSteps[item.slug] = recipe

        for inputStack in recipe.input
            @_findSteps inputStack.slug

        @_addStep recipe

    _hasStep: (slug)->
        return true if @steps[slug]?
        return true if @_reservedSteps[slug]?
        return false

    _removeExtraSteps: ->
        result = (step for step in @steps when step.multiplier > 0)
        @steps = result

    _resolveNeeds: ->
        for i in [@steps.length-1..0] by -1
            step   = @steps[i]
            recipe = step.recipe

            step.multiplier = Math.ceil(@need.quantityOf(recipe.slug) / step.recipe.output[0].quantity)

            if @includingTools
                for stack in recipe.tools
                    slug      = stack.slug
                    available = @result.quantityOf(slug) + @need.quantityOf(slug)
                    needed    = Math.max 0, stack.quantity - available

                    @need.add stack.slug, needed
                    @result.add stack.slug, needed

            for stack in recipe.input
                needed    = step.multiplier * stack.quantity
                consumed  = Math.min needed, @result.quantityOf(stack.slug)
                remaining = needed - consumed

                @result.remove stack.slug, consumed
                @need.add stack.slug, remaining

            for stack in recipe.output
                created   = stack.quantity * step.multiplier
                consumed  = Math.min created, @need.quantityOf stack.slug
                remaining = created - consumed

                @result.add stack.slug, remaining
                @need.remove stack.slug, consumed
