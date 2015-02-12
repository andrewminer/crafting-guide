###
Crafting Guide - item.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseCollection = require './base_collection'
BaseModel      = require './base_model'
{Event}        = require '../constants'
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
        attributes.slug         ?= _.slugify attributes.name

        options.logEvents       ?= false
        super attributes, options

        Object.defineProperties this,
            isCraftable:   {get:@getIsCraftable}
            qualifiedSlug: {get:@getQualifiedSlug}

        @on Event.change + ':modVersion', => @_qualifiedSlug = null

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
        return @modVersion.hasRecipes @qualifiedSlug

    getQualifiedSlug: ->
        return @slug if not @modVersion?

        if not @_qualifiedSlug?
            @_qualifiedSlug = _.composeSlugs @modVersion.modSlug, @slug

        return @_qualifiedSlug

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
            .onlyIf (_.slugify(@name) isnt @slug), (b)=>
                b.push 'slug:"', @slug, '", '
            .push '}'
            .toString()
