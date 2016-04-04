#
# Crafting Guide - item.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel       = require '../base_model'
ItemSlug        = require './item_slug'
Recipe          = require './recipe'
{StringBuilder} = require 'crafting-guide-common'

########################################################################################################################

module.exports = class Item extends BaseModel

    @Group = Other:'Other'

    constructor: (attributes={}, options={})->
        if not attributes.name? then throw new Error 'attributes.name is required'

        attributes.description          ?= null
        attributes.group                ?= Item.Group.Other
        attributes.ignoreDuringCrafting ?= false
        attributes.isGatherable         ?= false
        attributes.modVersion           ?= null
        attributes.officialUrl          ?= null
        attributes.slug                 ?= ItemSlug.slugify attributes.name
        attributes.videos               ?= []

        options.logEvents ?= false
        super attributes, options

        @on c.event.change + ':modVersion', =>
            @_isCraftable = null
            @slug.mod = @modVersion?.modSlug

    # Public Methods ###############################################################################

    compareTo: (that)->
        if this.slug isnt that.slug
            return if this.slug < that.slug then -1 else +1
        if this.name isnt that.name
            return if this.name < that.name then -1 else +1
        return 0

    unparse: ->
        ItemParser = require '../parsing/item_parser' # to avoid require cycles
        @_parser ?= new ItemParser model:this
        return @_parser.unparse()

    # Property Methods #############################################################################

    getIsCraftable: ->
        if not @_isCraftable?
            @_isCraftable = false
            if @modVersion?
                @_isCraftable = @modVersion.hasRecipes @slug

        return @_isCraftable

    Object.defineProperties @prototype,
        isCraftable: {get:@prototype.getIsCraftable}

    # Backbone.Model Overrides #####################################################################

    parse: (text)->
        ItemParser = require '../parsing/item_parser' # to avoid require cycles
        @_parser ?= new ItemParser model:this
        @_parser.parse text

        return null # prevent calling `set`

    url: ->
        return c.url.itemData modSlug:@slug.mod, itemSlug:@slug.item

    # Object Overrides #############################################################################

    toString: ->
        builder = new StringBuilder
        return builder
            .push @constructor.name, ' (', @cid, ') { '
            .push 'name:"', @name, '", '
            .push 'isCraftable:', @isCraftable, ', '
            .push 'isGatherable:', @isGatherable, ', '
            .onlyIf (@group isnt Item.Group.Other), (b)=>
                b.push 'group:"', @group, '", '
            .push 'slug:"', @slug, '", '
            .push '}'
            .toString()
