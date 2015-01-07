###
Crafting Guide - item_page_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController          = require './base_controller'
CraftingTableController = require './crafting_table_controller'
ImageLoader             = require './image_loader'
InventoryController     = require './inventory_controller'
ItemPage                = require '../models/item_page'
ModPackController       = require './mod_pack_controller'

########################################################################################################################

module.exports = class ItemPageController extends BaseController

    constructor: (options={})->
        options.model        ?= new ItemPage
        options.imageLoader  ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.templateName  = 'item_page'
        super options

    # Public Methods ###############################################################################

    setParams: (params)->
        return unless params.name?

        item = @model.modPack.findItemByName params.name
        return unless item? and item.isCraftable

        quantity = if params.quantity? then parseInt(params.quantity) else 1
        @model.want.add item.slug, quantity

    # BaseController Overrides #####################################################################

    onDidRender: ->
        options =
            editable:    true,
            imageLoader: @imageLoader
            model:       @model.plan.have,
            modPack:     @model.modPack,
            title:       'Items you have'
        @haveController = @addChild InventoryController, '.have', options

        options =
            editable:    true
            icon:        '/images/fishing_rod.png',
            imageLoader: @imageLoader
            model:       @model.plan.want,
            modPack:     @model.modPack,
            title:       'Items you want'
        @wantController = @addChild InventoryController, '.want', options

        options =
            editable:    false
            icon:        '/images/boots.png',
            imageLoader: @imageLoader
            model:       @model.plan.need,
            modPack:     @model.modPack,
            title:       "Items you'll need"
        @needController = @addChild InventoryController, '.need', options

        @modPackController = @addChild ModPackController, '.view__mod_pack', model:@model.modPack
        super
