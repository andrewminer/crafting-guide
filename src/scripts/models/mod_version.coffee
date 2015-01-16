###
Crafting Guide - mod_version.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{RequiredMods} = require '../constants'

########################################################################################################################

module.exports = class ModVersion extends BaseModel

    constructor: (attributes={}, options={})->
        if _.isEmpty(attributes.name) then throw new Error 'name cannot be empty'
        if _.isEmpty(attributes.version) then throw new Error 'version cannot be empty'

        attributes.description  ?= ''
        attributes.enabled      ?= true
        attributes.items        ?= {}
        attributes.names        ?= {}
        attributes.slug         ?= _.slugify attributes.name
        super attributes, options

    # Public Methods ###############################################################################

    addItem: (item)->
        if item.modVersion isnt this then throw new Error "cannot add item not associated with this mod version"
        if @items[item.slug]? then throw new Error "duplicate item for #{item.name}"

        @items[item.slug] = item
        @names[item.slug] = item.name
        return this

    compareTo: (that)->
        if this.name is that.name then return 0

        thisRequired = this.name in RequiredMods
        thatRequired = that.name in RequiredMods

        if thisRequired and thatRequired
            return if this.name < that.name then -1 else +1
        else if thisRequired
            return -1
        else if thatRequired
            return +1
        else
            return if this.name < that.name then -1 else +1

    findItemByName: (name)->
        slug = _.slugify name
        return @items[slug]

    findName: (slug)->
        return @names[slug]

    hasRecipe: (name)->
        item = @findItemByName name
        return false unless item?
        return item.recipes.length > 0

    registerSlug: (slug, name)->
        @names[slug] = name

    # Object Overrides #############################################################################

    toString: ->
        return "ModVersion (#{@cid}) {
            enabled:#{@enabled},
            name:#{@name},
            version:#{@version},
            items:#{_.keys(@items).length} items}"
