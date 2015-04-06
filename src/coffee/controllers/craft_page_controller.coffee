###
Crafting Guide - craft_page_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

CraftingTableController = require './crafting_table_controller'
CraftPage               = require '../models/craft_page'
{Event}                 = require '../constants'
ImageLoader             = require './image_loader'
InventoryController     = require './inventory_controller'
ModPackController       = require './mod_pack_controller'
NameFinder              = require '../models/name_finder'
PageController          = require './page_controller'
Storage                 = require '../models/storage'
{Text}                  = require '../constants'
{Url}                   = require '../constants'

########################################################################################################################

module.exports = class CraftPageController extends PageController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        options.model        ?= new CraftPage modPack:options.modPack
        options.storage      ?= new Storage storage:window.localStorage
        options.templateName  = 'craft_page'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack
        @storage     = options.storage

    # Event Methods ################################################################################

    onToolsBoxToggled: ->
        @model.plan.includingTools = @$('.includeTools:checked').length isnt 0

    # PageController Overrides #####################################################################

    getTitle: ->
        return 'Craft'

    # BaseController Overrides #####################################################################

    onWillRender: ->
        @storage.register 'crafting-plan', @model.plan, 'includingTools'
        @model.plan.have.clear()
        @model.plan.have.parse @storage.load('crafting-plan:have')
        super

    onDidRender: ->
        @wantController = @addChild InventoryController, '.want',
            editable:     true
            icon:         '/images/fishing_rod.png'
            imageLoader:  @imageLoader
            isAcceptable: (item)-> item.isCraftable
            model:        @model.plan.want
            modPack:      @model.modPack
            onChange:     => @_updateLocation()
            title:        'Items you want'

        @haveController = @addChild InventoryController, '.have',
            editable:    true,
            imageLoader: @imageLoader
            model:       @model.plan.have
            modPack:     @model.modPack
            onChange:    => @_saveHaveInventory()
            title:       'Items you have'

        @needController = @addChild InventoryController, '.need',
            editable:    false
            icon:        '/images/boots.png'
            imageLoader: @imageLoader
            model:       @model.plan.need
            modPack:     @model.modPack
            title:       "Items you'll need"

        @craftingTableController = @addChild CraftingTableController, '.view__crafting_table',
            imageLoader: @imageLoader
            model:       @model.table
            modPack:     @model.modPack

        @$('.want .toolbar').append '<label><input class="includeTools" type="checkbox"> include tools</label>'
        @$includeToolsBox = @$('.includeTools')

        super

    refresh: ->
        if @model.plan.includingTools
            @$includeToolsBox.attr 'checked', 'checked'
        else
            @$includeToolsBox.removeAttr 'checked'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'change .includeTools': 'onToolsBoxToggled'

    # Private Methods ##############################################################################

    _saveHaveInventory: ->
        @storage.store 'crafting-plan:have', @model.plan.have.unparse()

    _updateLocation: ->
        text = @model.plan.want.unparse()
        url = Url.crafting inventoryText:text
        router.navigate url
