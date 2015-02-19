###
Crafting Guide - item.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel      = require './base_model'
{Event}        = require '../constants'
ItemSlug       = require './item_slug'
Recipe         = require './recipe'
StringBuilder  = require './string_builder'

########################################################################################################################

module.exports = class Item extends BaseModel

    @Group = Other:'Other'

    constructor: (attributes={}, options={})->
        if not attributes.name? then throw new Error 'attributes.name is required'

        attributes.group        ?= Item.Group.Other
        attributes.isGatherable ?= false
        attributes.modVersion   ?= null
        attributes.slug         ?= ItemSlug.slugify attributes.name

        options.logEvents       ?= false
        super attributes, options

        @on Event.change + ':modVersion', => @slug.mod = @modVersion?.modSlug

    # Public Methods ###############################################################################

    compareTo: (that)->
        if this.slug isnt that.slug
            return if this.slug < that.slug then -1 else +1
        if this.name isnt that.name
            return if this.name < that.name then -1 else +1
        return 0

    # Property Methods #############################################################################

    getIsCraftable: ->
        return false unless @modVersion?
        return @modVersion.hasRecipes @slug

    Object.defineProperties @prototype,
        isCraftable: {get:@prototype.getIsCraftable}

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
