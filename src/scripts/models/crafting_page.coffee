###
Crafting Guide - crafting_page.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel       = require './base_model'
CraftingPlan    = require './crafting_plan'
CraftingTable   = require './crafting_table'
{Event}         = require '../constants'
InventoryParser = require './inventory_parser'
ModPack         = require './mod_pack'

########################################################################################################################

module.exports = class CraftingPage extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.modPack ?= new ModPack
        attributes.params  ?= null
        attributes.plan    ?= new CraftingPlan modPack:attributes.modPack
        attributes.table   ?= new CraftingTable plan:attributes.plan
        super attributes, options

        @_parser = new InventoryParser

        @modPack.on Event.change, => @_consumeParams()
        @on Event.change + ':params', => @_consumeParams()

    # Private Methods ##############################################################################

    _consumeParams: ->
        return unless @params?

        @plan.want.clear()
        if not @params.inventoryText?
            @params = null
        else
            inventory = @_parser.parse @params.inventoryText

            inventory.each (stack)=>
                item = @modPack.findItem stack.slug, enableAsNeeded:true
                return unless item? and item.isCraftable
                @plan.want.add stack.slug, stack.quantity
                inventory.remove stack.slug

            if inventory.isEmpty then @params = null
