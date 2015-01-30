###
Crafting Guide - item_group_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Duration}     = require '../constants'
{Event}        = require '../constants'
Item           = require '../models/item'
ItemController = require './item_controller'

########################################################################################################################

module.exports = class ItemGroupController extends BaseController

    constructor: (options={})->
        if not options.model?      then throw new Error 'options.model is required'
        if not options.modPack?    then throw new Error 'options.modPack is required'
        if not options.modVersion? then throw new Error 'options.modVersion is required'
        options.templateName = 'item_group'
        super options

        @modVersion       = options.modVersion
        @_modPack         = options.modPack
        @_itemControllers = []

        @modVersion.on Event.change, => @refresh()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$title = @$('h2')
        @$items = @$('.panel')
        super

    refresh: ->
        @$title.html if @model is Item.Group.Other then 'Items' else @model
        @_refreshItems()
        super

    # Private Methods ##############################################################################

    _createItemController: (item)->
        controller = new ItemController model:item, modPack:@_modPack
        controller.$el.hide()
        controller.render()

        @_itemControllers.push controller
        @$items.append controller.$el
        controller.$el.slideDown duration:Duration.fast

    _refreshItems: ->
        controllerIndex = 0
        delay = 0

        @modVersion.eachItemInGroup @model, (item)=>
            controller = @_itemControllers[controllerIndex]
            if not controller?
                _.delay (=> @_createItemController item), delay
                delay += @_delayStep
            else
                controller.model = item
                controller.refresh()
            controllerIndex += 1

        while @_itemControllers.length > controllerIndex
            controller = @_itemControllers.pop()
            controller.$el.slideUp duration:Duration.fast, complete:-> @remove()
