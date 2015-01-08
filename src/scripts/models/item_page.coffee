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
        attributes.plan    ?= new CraftingPlan modPack:attributes.modPack
        attributes.table   ?= new CraftingTable plan:attributes.plan
        super attributes, options
