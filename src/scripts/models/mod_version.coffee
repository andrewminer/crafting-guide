###
Crafting Guide - mod_version.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{RequiredMods} = require '../constants'

########################################################################################################################

module.exports = class ModVersion extends BaseModel

    constructor: (attributes={}, options={})->
        if _.isEmpty(attributes.modName) then throw new Error 'modName cannot be empty'
        if _.isEmpty(attributes.modVersion) then throw new Error 'modVersion cannot be empty'

        attributes.description  ?= ''
        attributes.items        ?= {}
        attributes.enabled      ?= attributes.modName in RequiredMods
        super attributes, options

    # Public Methods ###############################################################################

    addItem: (item)->
        if @items[item.slug]? then throw new Error "duplicate item for #{item.slug}"
        @items[item.slug] = item
        return this

    compareTo: (that)->
        if this.modName is that.modName then return 0

        thisRequired = this.modName in RequiredMods
        thatRequired = that.modName in RequiredMods

        if thisRequired and thatRequired
            return if this.modName < that.modName then -1 else +1
        else if thisRequired
            return -1
        else if thatRequired
            return +1
        else
            return if this.modName < that.modName then -1 else +1

    findItemByName: (name)->
        slug = _.slugify name
        return @items[slug]

    gatherRecipeNames: (result={})->
        for slug, item of @items
            continue if result[item.slug]
            continue unless item.isCraftable
            result[item.slug] = value:item.name, label:"#{item.name} (from #{@modName} #{@modVersion})"

        return result

    hasRecipe: (name)->
        item = @findItemByName name
        return false unless item?
        return item.recipes.length > 0

    # Object Overrides #############################################################################

    toString: ->
        return "ModVersion (#{@cid}) {
            enabled:#{@enabled},
            modName:#{@modName},
            modVersion:#{@modVersion},
            items:#{_.keys(@items).length} items}"
