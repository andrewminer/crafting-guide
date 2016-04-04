#
# Crafting Guide - item_node.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingNode = require './crafting_node'
RecipeNode   = require './recipe_node'

########################################################################################################################

module.exports = class ItemNode extends CraftingNode

    @::ENTER_METHOD = 'onEnterItemNode'
    @::LEAVE_METHOD = 'onLeaveItemNode'
    @::TYPE = CraftingNode::TYPES.ITEM

    constructor: (options={})->
        if not options.item? then throw new Error 'options.item is required'
        super options

        @item = options.item
        @_ignoreGatherable = options.ignoreGatherable ?= false
        @_recipes = null

    # Property Methods #############################################################################

    getRecipes: ->
        if not @_recipes?
            @_recipes = @modPack.findRecipes @item.slug, forCrafting:true, onlyPrimary:true
            if not @_recipes
                @_recipes = @modPack.findRecipes @item.slug, forCrafting:true

        return @_recipes or []

    isGatherable: ->
        if not @_ignoreGatherable
            return true if @item.isGatherable
        return true if @getRecipes().length is 0
        return false

    Object.defineProperties @prototype,
        gatherable: { get:@prototype.isGatherable }
        recipes: { get:@prototype.getRecipes }

    # CraftingNode Overrides #######################################################################

    _createChildren: (result=[])->
        recipes = @getRecipes()
        return [] if @gatherable

        for recipe in recipes
            child = new RecipeNode modPack:@modPack, recipe:recipe
            child.parent = this
            if child.valid
                result.push child

        return result

    _checkCompleteness: ->
        return true if @gatherable
        return false unless @children?

        for child in @children
            return true if child.complete
        return false

    _checkValidity: ->
        return false if @_isRepeatedItem()
        return true unless @children.length > 0

        for child in @children
            return true if child.valid
        return false

    # Object Overrides #############################################################################

    toString: (options={})->
        options.indent ?= ''
        options.recursive ?= true

        parts = ["#{options.indent}#{@completeText} #{@validText} ItemNode for #{@item.name}"]
        nextIndent = options.indent + '    '
        if options.recursive
            for child in @children
                parts.push child.toString indent:nextIndent
        return parts.join '\n'

    # Private Methods ##############################################################################

    _isRepeatedItem: ->
        nextParent = @parent
        while nextParent?
            return true if nextParent.item is @item
            nextParent = nextParent.parent

        return false
