###
Crafting Guide - item_node.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

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
        @_recipes = null

    # Property Methods #############################################################################

    getRecipes: ->
        if not @_recipes?
            @_recipes = @modPack.findRecipes @item.slug
        return @_recipes or []

    isGatherable: ->
        return true if @item.isGatherable
        return true unless @getRecipes().length > 0
        return false

    Object.defineProperties @prototype,
        gatherable: { get:@prototype.isGatherable }
        recipes: { get:@prototype.getRecipes }

    # CraftingNode Overrides #######################################################################

    _createChildren: (result=[])->
        recipes = @getRecipes()
        return [] unless recipes.length > 0

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
