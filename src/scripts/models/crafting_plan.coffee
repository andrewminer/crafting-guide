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
        options.storage ?= window.localStorage

        if not attributes.modPack then throw new Error 'modPack is required'
        attributes.includingTools ?= options.storage.getItem('includingTools')
        attributes.includingTools ?= false
        super attributes, options

        @have    = new Inventory
        @want    = new Inventory
        @need    = new Inventory
        @result  = new Inventory
        @storage = options.storage

        @have.on 'change', => @craft()
        @want.on 'change', => @craft()
        @modPack.on 'change', => @craft()
        @on 'change:includingTools', => @onIncludingToolsChanged()

        @clear()

    # Public Methods ###############################################################################

    clear: ->
        @steps = []
        @need.clear()
        @result.clear()

        @trigger 'change', this
        return this

    craft: ->
        @clear()
        @result.addInventory @have

        @steps = {}
        @want.each (stack)=>
            @_findSteps stack.itemSlug
            @need.add stack.itemSlug, stack.quantity

        @steps = _.values @steps
        @_resolveNeeds()
        @_removeExtraSteps()
        @result.addInventory @want

        @trigger 'change', this

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
        return if @_hasStep recipe.slug
        logger.verbose "adding step: #{recipe.slug}"
        @steps[recipe.slug] = recipe:recipe

    _chooseRecipe: (item)->
        return item.recipes[0]

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

        for inputStack in recipe.input
            @_findSteps inputStack.itemSlug

        @_addStep recipe

    _hasStep: (itemSlug)->
        return @steps[itemSlug]?

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
                    slug      = stack.itemSlug
                    available = @result.quantityOf(slug) + @need.quantityOf(slug)
                    needed    = Math.max 0, stack.quantity - available

                    @need.add stack.itemSlug, needed
                    @result.add stack.itemSlug, needed

            for stack in recipe.input
                needed    = step.multiplier * stack.quantity
                consumed  = Math.min needed, @result.quantityOf(stack.itemSlug)
                remaining = needed - consumed

                @result.remove stack.itemSlug, consumed
                @need.add stack.itemSlug, remaining

            for stack in recipe.output
                created   = stack.quantity * step.multiplier
                consumed  = Math.min created, @need.quantityOf stack.itemSlug
                remaining = created - consumed

                @result.add stack.itemSlug, remaining
                @need.remove stack.itemSlug, consumed
