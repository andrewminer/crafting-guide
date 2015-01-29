###
Crafting Guide - item_page.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel     = require './base_model'
CraftingPlan  = require './crafting_plan'
CraftingTable = require './crafting_table'
{Event}       = require '../constants'
ModPack       = require './mod_pack'

########################################################################################################################

module.exports = class ItemPage extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.modPack ?= new ModPack
        attributes.params  ?= null
        attributes.plan    ?= new CraftingPlan modPack:attributes.modPack
        attributes.table   ?= new CraftingTable plan:attributes.plan
        super attributes, options

        @modPack.on Event.change, => @_consumeParams()
        @on Event.change + ':params', => @_consumeParams()

    # Private Methods ##############################################################################

    _consumeParams: ->
        return unless @params?

        if not @params?.name?
            @plan.want.clear()
            @params = null
        else
            item = @modPack.findItemByName @params.name
            return unless item? and item.isCraftable

            quantity = if @params.quantity? then parseInt(@params.quantity) else 1
            @plan.want.add item.slug, quantity

            @params = null
