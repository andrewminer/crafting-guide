#
# Crafting Guide - recipe_node.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingNode = require './crafting_node'
Item         = require '../game/item'
# ItemNode   = require './item_node' # don't include here, causes a cycle
ItemSlug     = require '../game/item_slug'

########################################################################################################################

module.exports = class RecipeNode extends CraftingNode

    @::ENTER_METHOD = 'onEnterRecipeNode'
    @::LEAVE_METHOD = 'onLeaveRecipeNode'
    @::TYPE = CraftingNode::TYPES.RECIPE

    constructor: (options={})->
        if not options.recipe? then throw new Error 'options.recipe is required'
        super options

        @recipe = options.recipe

    # CraftingNode Overrides #######################################################################

    _createChildren: (result=[])->
        ItemNode = require './item_node' # include here to avoid a cycle

        for stack in @recipe.input
            item = @modPack.findItem stack.itemSlug
            if not item?
                name = @modPack.findName stack.itemSlug
                item = new Item name:name, slug:stack.itemSlug, gatherable:true
            result.push new ItemNode modPack:@modPack, item:item
        return result

    _checkCompleteness: ->
        for child in @children
            return false unless child.complete
        return true

    _checkValidity: ->
        return false if @_isRepeatedRecipe()
        return false if @_requiresToolBeingMade()

        for child in @children
            return false unless child.valid

        return true

    # Private Methods ##############################################################################

    _isRepeatedRecipe: ->
        nextParent = @parent
        while nextParent?
            return true if nextParent.recipe is @recipe
            nextParent = nextParent.parent

        return false

    _requiresToolBeingMade: ->
        for toolStack in @recipe.tools
            toolSlug = toolStack.itemSlug

            nextParent = @parent
            while nextParent?
                if ItemSlug.equal toolSlug, nextParent.item?.slug
                    return true
                nextParent = nextParent.parent

        return false

    # Object Overrides ############################################################################

    toString: (options={})->
        options.indent ?= ''
        options.recursive ?= true

        parts = ["#{options.indent}#{@completeText} #{@validText} RecipeNode for #{@recipe.slug}"]
        nextIndent = options.indent + '    '
        if options.recursive
            for child in @children
                parts.push child.toString indent:nextIndent
        return parts.join '\n'
