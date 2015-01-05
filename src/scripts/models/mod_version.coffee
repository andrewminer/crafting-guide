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
        attributes.enabled      ?= attributes.name in RequiredMods
        attributes.items        ?= {}
        attributes.names        ?= {}
        attributes.slug         ?= _.slugify attributes.name
        super attributes, options

    # Public Methods ###############################################################################

    addItem: (item)->
        if @items[item.slug]? then throw new Error "duplicate item for #{item.slug}"
        @items[item.slug] = item
        item.modVersion = this
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

    gatherRecipeNames: (result={})->
        for slug, item of @items
            continue if result[item.slug]
            continue unless item.isCraftable
            result[item.slug] = value:item.name, label:"#{item.name} (from #{@name} #{@version})"

        return result

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
