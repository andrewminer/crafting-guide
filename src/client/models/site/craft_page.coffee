#
# Crafting Guide - craft_page.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'
Craftsman = require '../crafting/craftsman'
Inventory = require '../game/inventory'
ModPack   = require '../game/mod_pack'

########################################################################################################################

module.exports = class CraftPage extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.modPack then throw new Error 'attributes.modPack is required'
        attributes.params    ?= null
        attributes.craftsman ?= new Craftsman attributes.modPack
        super attributes, options

        @modPack.on c.event.change, => @_consumeParams()
        @on c.event.change + ':params', => @_consumeParams()
        @craftsman.on c.event.change + ':stage', => @trigger c.event.change, this
        @craftsman.on c.event.change + ':complete', => @trigger c.event.change, this

    # Private Methods ##############################################################################

    _consumeParams: ->
        return unless @params?

        @craftsman.want.clear()
        if not @params.inventoryText?
            @params = null
        else
            inventory = new Inventory
            inventory.parse @params.inventoryText

            inventory.each (stack)=>
                item = @modPack.findItem stack.itemSlug, enableAsNeeded:true
                return unless item? and item.isCraftable
                @craftsman.want.add stack.itemSlug, stack.quantity
                inventory.remove stack.itemSlug

            if inventory.isEmpty then @params = null
