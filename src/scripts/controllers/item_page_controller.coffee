###
Crafting Guide - item_page_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController          = require './base_controller'
CraftingTableController = require './crafting_table_controller'
InventoryController     = require './inventory_controller'
ItemPage                = require '../models/item_page'
ModPackController       = require './mod_pack_controller'

########################################################################################################################

module.exports = class ItemPageController extends BaseController

    constructor: (options={})->
        options.model        ?= new ItemPage
        options.templateName  = 'item_page'
        super options

    # Public Methods ###############################################################################

    setParams: (params)->
        @model.table.name     = params.name     if params.name?
        @model.table.quantity = params.quantity if params.quantity?

    # BaseController Overrides #####################################################################

    onDidRender: ->
        options = model:@model.table.have, modPack:@model.modPack, editable:true
        @haveController = @addChild InventoryController, '.view__inventory.have', options

        options =
            editable: false
            icon:     '/images/workbench_top.png',
            model:    @model.table.want,
            modPack:  @model.modPack,
            title:    'Items to Craft'
        @wantController = @addChild InventoryController, '.view__inventory.want', options

        @modPackController = @addChild ModPackController, '.view__mod_pack', model:@model.modPack
        @tableController = @addChild CraftingTableController, '.view__crafting_table', model:@model.table
        super
