###
Crafting Guide - recipe_node.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

CraftingNode = require './crafting_node'
# ItemNode     = require './item_node' # don't include here, causes a cycle

########################################################################################################################

module.exports = class RecipeNode extends CraftingNode

    @::ENTER_METHOD = 'onEnterRecipeNode'
    @::LEAVE_METHOD = 'onLeaveRecipeNode'

    constructor: (options={})->
        if not options.recipe? then throw new Error 'options.recipe is required'
        super options

        @recipe = options.recipe

    # CraftingNode Overrides #######################################################################

    _createChildren: (result=[])->
        ItemNode = require './item_node' # include here to avoid a cycle

        for stack in @recipe.input
            item = @modPack.findItem stack.itemSlug
            result.push new ItemNode modPack:@modPack, item:item
        return result

    _checkCompleteness: ->
        for child in @children
            return false unless child.isComplete
        return true

    _checkValidity: ->
        for child in @children
            return false unless child.isValid

        return false if @_isRepeatedRecipe()
        return true

    # Private Methods ##############################################################################

    _isRepeatedRecipe: ->
        nextParent = @parent
        while nextParent?
            return true if nextParent.recipe is @recipe
            nextParent = nextParent.parent

        return false

    # Object Overrides ############################################################################

    toString: (options={})->
        options.indent ?= ''
        options.recursive ?= true

        completeText = if @complete then 'complete' else 'incomplete'
        parts = ["#{options.indent}#{@completeText} RecipeNode for #{@recipe.slug}"]
        nextIndent = options.indent + '    '
        if options.recursive
            for child in @children
                parts.push child.toString indent:nextIndent
        return parts.join '\n'
