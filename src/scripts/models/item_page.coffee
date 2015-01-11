###
Crafting Guide - item_page.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel     = require './base_model'
CraftingPlan  = require './crafting_plan'
CraftingTable = require './crafting_table'
ModPack       = require './mod_pack'

########################################################################################################################

module.exports = class ItemPage extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.modPack ?= new ModPack
        attributes.params  ?= null
        attributes.plan    ?= new CraftingPlan modPack:attributes.modPack
        attributes.table   ?= new CraftingTable plan:attributes.plan
        super attributes, options

        @modPack.on 'change', => @_consumeParams()
        @plan.on 'change', => @_updateLocation()

    # Private Methods ##############################################################################

    _consumeParams: ->
        return unless @params?.name?

        item = @modPack.findItemByName @params.name, includeDisabled:true
        return unless item? and item.isCraftable

        quantity = if @params.quantity? then parseInt(@params.quantity) else 1
        @plan.want.add item.slug, quantity

        @params = null

    _updateLocation: ->
        list = @plan.want.toList()
        if list.length is 1
            itemSlug = if _.isArray(list[0]) then list[0][1] else list[0]
            router.navigate "/item/#{itemSlug}"
        else
            router.navigate "/"