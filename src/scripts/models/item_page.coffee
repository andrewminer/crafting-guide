###
# Crafting Guide - item_page.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel     = require './base_model'
CraftingTable = require './crafting_table'
ModPack = require './mod_pack'

########################################################################################################################

module.exports = class ItemPage extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.modPack ?= new ModPack
        attributes.table ?= new CraftingTable modPack:attributes.modPack
        super attributes, options
