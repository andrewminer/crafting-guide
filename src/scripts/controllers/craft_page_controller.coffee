###
Crafting Guide - craft_page_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController          = require './base_controller'
CraftingTableController = require './crafting_table_controller'
{Event}                 = require '../constants'
ImageLoader             = require './image_loader'
InventoryController     = require './inventory_controller'
CraftPage               = require '../models/craft_page'
ModPackController       = require './mod_pack_controller'
NameFinder              = require '../models/name_finder'
Storage                 = require '../models/storage'
{Text}                  = require '../constants'
{Url}                   = require '../constants'

########################################################################################################################

module.exports = class CraftPageController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        options.model        ?= new CraftPage modPack:options.modPack
        options.storage      ?= new Storage storage:window.localStorage
        options.templateName  = 'craft_page'
        super options

        @_imageLoader = options.imageLoader
        @_storage     = options.storage

    # Event Methods ################################################################################

    onToolsBoxToggled: ->
        @model.plan.includingTools = @$('.includeTools:checked').length isnt 0

    # BaseController Overrides #####################################################################

    onWillRender: ->
        @_storage.register 'crafting-plan', @model.plan, 'includingTools'
        @model.plan.have.clear()
        @model.plan.have.parse @_storage.load('crafting-plan:have')
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
            onChange:    => @_saveHaveInventory()
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
        $('title').html Text.title

        if @model.plan.includingTools
            @$includeToolsBox.attr 'checked', 'checked'
        else
            @$includeToolsBox.removeAttr 'checked'

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'change .includeTools': 'onToolsBoxToggled'

    # Private Methods ##############################################################################

    _saveHaveInventory: ->
        @_storage.store 'crafting-plan:have', @model.plan.have.unparse()

    _updateLocation: ->
        text = @model.plan.want.unparse()
        url = Url.crafting inventoryText:text
        router.navigate url
