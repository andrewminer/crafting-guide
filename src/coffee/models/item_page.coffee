###
Crafting Guide - item_page.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel    = require './base_model'
CraftingPlan = require './crafting_plan'
{Event}      = require '../constants'
{Url}        = require '../constants'

########################################################################################################################

module.exports = class ItemPage extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.modPack? then throw new Error 'attributes.modPack is required'
        attributes.item ?= null
        super attributes, options

    # Property Methods #############################################################################

    compileDescription: ->
        return null unless @item?.description?

        tree = markdown.parse @item.description, 'Maruku'
        refs = tree[1].references

        findLinkRefs = (node)=>
            logger.debug "inspecting a #{node[0]}"
            if node[0] is 'link_ref'
                name = node[2]
                logger.debug "found a link_ref for #{name}"
                item = @modPack.findItemByName node[2]
                if item?
                    logger.debug "found related item: #{item}"
                    node[0] = 'link'
                    node[1].href = Url.item itemSlug:item.slug.item, modSlug:item.slug.mod
                    delete node[1].ref
            else
                for index in [1...node.length]
                    if _.isArray node[index]
                        for child in node[index]
                            logger.indent()
                            findLinkRefs child
                            logger.outdent()

        findLinkRefs tree

        html = markdown.renderJsonML markdown.toHTMLTree tree
        return html

    findComponentInItems: ->
        return @_findRecipesMatching (recipe)=> recipe.requires @item.slug

    findSimilarItems: ->
        return null unless @item?.modVersion?

        result = []
        @item.modVersion.eachItemInGroup @item.group, (item)=>
            result.push item

        return null unless result.length > 0
        return result

    findRecipes: ->
        return @modPack.findRecipes @item?.slug, [], alwaysFromOwningMod:true

    findToolForRecipes: ->
        return @_findRecipesMatching (recipe)=> recipe.requiresTool @item.slug

    # Private Methods ##############################################################################

    _findRecipesMatching: (callback)->
        return null unless @item?

        result = {}
        @modPack.eachMod (mod)=>
            mod.eachRecipe (recipe)=>
                if callback(recipe)
                    outputItem = @modPack.findItem recipe.itemSlug, includeDisabled:true
                    result[outputItem.slug] = outputItem

        result = _.values result
        return null unless result.length > 0

        return result.sort (a, b)-> a.compareTo b