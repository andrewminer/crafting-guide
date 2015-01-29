###
Crafting Guide - item_page_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController          = require './base_controller'
CraftingTableController = require './crafting_table_controller'
{Event}                 = require '../constants'
ImageLoader             = require './image_loader'
InventoryController     = require './inventory_controller'
ItemPage                = require '../models/item_page'
ModPackController       = require './mod_pack_controller'
NameFinder              = require '../models/name_finder'
Storage                 = require '../models/storage'

########################################################################################################################

module.exports = class ItemPageController extends BaseController

    constructor: (options={})->
        options.model        ?= new ItemPage modPack:options.modPack
        options.imageLoader  ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.storage      ?= new Storage storage:window.localStorage
        options.templateName  = 'item_page'
        super options

        @_imageLoader = options.imageLoader
        @_storage     = options.storage

    # Event Methods ################################################################################

    onToolsBoxToggled: ->
        @model.plan.includingTools = @$('.includeTools:checked').length isnt 0

    # BaseController Overrides #####################################################################

    onWillRender: ->
        @_storage.register 'crafting-plan', @model.plan, 'includingTools'
        super

    onDidRender: ->
        @wantController = @addChild InventoryController, '.want',
            editable:    true
            icon:        '/images/fishing_rod.png'
            imageLoader: @_imageLoader
            model:       @model.plan.want
            modPack:     @model.modPack
            onChange:    => @_updateLocation()
            title:       'Items you want'

        @haveController = @addChild InventoryController, '.have',
            editable:    true,
            imageLoader: @_imageLoader
            model:       @model.plan.have
            modPack:     @model.modPack
            nameFinder:  new NameFinder @model.modPack, includeGatherable:true
            title:       'Items you have'

        @needController = @addChild InventoryController, '.need',
            editable:    false
            icon:        '/images/boots.png'
            imageLoader: @_imageLoader
            model:       @model.plan.need
            modPack:     @model.modPack
            title:       "Items you'll need"

        @craftingTableController = @addChild CraftingTableController, '.view__crafting_table',
            imageLoader: @_imageLoader
            model:       @model.table
            modPack:     @model.modPack

        @modPackController = @addChild ModPackController, '.view__mod_pack',
            model:       @model.modPack
            plan:        @model.plan
            storage:     @_storage

        @$('.want .toolbar').append '<label><input class="includeTools" type="checkbox"> include tools</label>'
        @$includeToolsBox = @$('.includeTools')

        super

    refresh: ->
        if @model.plan.includingTools
            @$includeToolsBox.attr 'checked', 'checked'
        else
            @$includeToolsBox.removeAttr 'checked'

    # Backbone.View Overrides ######################################################################

    events:
        'change .includeTools': 'onToolsBoxToggled'

    # Private Methods ##############################################################################

    _updateLocation: ->
        list = @model.plan.want.toList()
        if list.length is 1
            slug = if _.isArray(list[0]) then list[0][1] else list[0]
            router.navigate "/item/#{slug}"
        else
            router.navigate "/"
