###
# Crafting Guide - item_page_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseController          = require './base_controller'
CraftingTableController = require './crafting_table_controller'
ItemPage             = require '../models/item_page'
ModPackController = require './mod_pack_controller'

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
        @modPackController = @addChild ModPackController, '.view__mod_pack', model:@model.modPack
        @tableController = @addChild CraftingTableController, '.view__crafting_table', model:@model.table
        super
