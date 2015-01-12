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
        options.storage ?= window.localStorage

        if _.isEmpty(attributes.name) then throw new Error 'name cannot be empty'
        if _.isEmpty(attributes.version) then throw new Error 'version cannot be empty'

        attributes.description  ?= ''
        attributes.enabled      ?= true
        attributes.items        ?= {}
        attributes.names        ?= {}
        attributes.slug         ?= _.slugify attributes.name
        super attributes, options

        enabled = options.storage.getItem("#{@slug}.enabled")
        if enabled?
            logger.debug "loading #{@slug}.enabled as #{@enabled}"
            @enabled = enabled is 'true'
        @on 'change:enabled', =>
            logger.debug "saving #{@slug}.enabled as #{@enabled}"
            options.storage.setItem "#{@slug}.enabled", "#{@enabled}"

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

    gatherNames: (result={}, options={})->
        options.includeGatherable ?= false

        for slug, item of @items
            continue if result[item.slug]
            if not item.isCraftable
                continue unless options.includeGatherable
            result[item.slug] = value:item.name, label:"#{item.name} (from #{@name} #{@version})"

        if options.includeGatherable
            for slug, name of @names
                continue if result[slug]
                result[slug] = value:name, label:"#{name} (from #{@name} #{@version})"

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
