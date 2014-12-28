###
# Crafting Guide - item_page.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel     = require './base_model'
CraftingTable = require './crafting_table'
RecipeCatalog = require './recipe_catalog'

########################################################################################################################

module.exports = class ItemPage extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.catalog ?= new RecipeCatalog
        attributes.table ?= new CraftingTable catalog:attributes.catalog
        super attributes, options
