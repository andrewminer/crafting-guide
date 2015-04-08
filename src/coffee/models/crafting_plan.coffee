###
Crafting Guide - crafting_plan.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Event}   = require '../constants'
Inventory = require './inventory'
ItemSlug  = require './item_slug'

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
        haveMessage = if @have.isEmpty then '' else " starting with #{@have.unparse()}"
        logger.info => "crafting #{@want.unparse()}#{toolsMessage}#{haveMessage}"

        @clear()
        @have.localize()
        @want.localize()

        @result.addInventory @have

        @steps = {}
        @want.each (stack)=>
            @_findSteps stack.itemSlug, {}, ignoreGatherable:true
            item = @modPack.findItem stack.itemSlug
            @need.add item.slug, stack.quantity

        @steps = (step for recipeSlug, step of @steps)
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

    _chooseRecipe: (item)->
        recipes = @modPack.findRecipes item.slug
        return null unless recipes? and recipes.length > 0
        return recipes[0]

    _findSteps: (itemSlug, parentSteps={})->
        item = @modPack.findItem itemSlug
        return unless item?
        return unless item.isCraftable

        ignoreGatherable = @want.hasAtLeast itemSlug, 1
        if (not item.isGatherable) or ignoreGatherable
            recipes = @modPack.findRecipes item.slug
            recipes ?= []

            if parentSteps[item.slug]?
                logger.verbose -> "found cycle at #{item.slug}"
                throw new Error 'invalid recipe path'
            parentSteps[item.slug] = item

            logger.verbose -> "exploring: #{item.slug}"
            logger.indent()

            currentSteps = _.clone @steps
            foundValidRecipe = false
            for i in [0...recipes.length] by 1
                recipe = recipes[i]
                logger.verbose -> "trying recipe #{i+1} of #{recipes.length}: #{recipe.slug}"
                if @steps[recipe.slug]?
                    logger.verbose -> "already accepted this recipe"
                    foundValidRecipe = true
                    break

                try
                    if @includingTools
                        for toolStack in recipe.tools
                            if not @_hasStep toolStack.itemSlug
                                @_findSteps toolStack.itemSlug, parentSteps

                    for inputStack in recipe.input
                        @_findSteps inputStack.itemSlug, parentSteps

                    logger.verbose -> "adding step for: #{recipe.slug}"
                    @steps[recipe.slug] = recipe:recipe, itemSlug:item.slug
                    foundValidRecipe = true
                    break
                catch error
                    logger.verbose -> "recipe didn't work out: #{recipe.slug}"
                    if error.message isnt 'invalid recipe path' then throw error
                    @steps = _.clone currentSteps

            delete parentSteps[item.slug]
            logger.outdent()

        if not (foundValidRecipe or item.isGatherable)
            logger.verbose -> "could not find a valid recipe for #{item.slug}"
            throw new Error 'invalid recipe path'

    _hasStep: (itemSlug)->
        for recipeSlug, step of @steps
            return true if step.recipe.produces itemSlug
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
            outputQuantity = recipe.getQuantityProducedOf step.itemSlug

            step.multiplier = Math.ceil(@need.quantityOf(step.itemSlug) / outputQuantity)

            if @includingTools
                recipe.eachToolStack (stack)=>
                    itemSlug  = @_qualifyItemSlug stack.itemSlug
                    available = @result.quantityOf(itemSlug) + @need.quantityOf(itemSlug)
                    needed    = Math.max 0, stack.quantity - available

                    @need.add itemSlug, needed
                    @result.add itemSlug, needed

            recipe.eachInputStack (stack)=>
                itemSlug  = @_qualifyItemSlug stack.itemSlug
                needed    = step.multiplier * stack.quantity
                consumed  = Math.min needed, @result.quantityOf itemSlug
                remaining = needed - consumed

                @result.remove itemSlug, consumed
                @need.add itemSlug, remaining

            recipe.eachOutputStack (stack)=>
                itemSlug  = @_qualifyItemSlug stack.itemSlug
                created   = stack.quantity * step.multiplier
                consumed  = Math.min created, @need.quantityOf itemSlug
                remaining = created - consumed

                @result.add itemSlug, remaining
                @need.remove itemSlug, consumed
