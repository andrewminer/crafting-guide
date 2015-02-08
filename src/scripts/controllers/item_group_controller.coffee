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
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.title        ?= ''
        options.templateName  = 'item_group'
        super options

        @_itemControllers = []
        @_modPack         = options.modPack
        @_title           = options.title

        Object.defineProperties this,
            title: {get:@getTitle, set:@setTitle}

    # Property Methods #############################################################################

    getTitle: ->
        return @_title

    setTitle: (title)->
        @_title = title
        @tryRefresh()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$title = @$('h2')
        @$items = @$('.panel')
        super

    refresh: ->
        @$title.html @_title
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

        if @model?
            for item in @model
                controller = @_itemControllers[controllerIndex]
                if not controller?
                    _.delay ((i)=> return => @_createItemController i)(item), delay
                    delay += @_delayStep
                else
                    controller.model = item
                    controller.refresh()
                controllerIndex += 1

        while @_itemControllers.length > controllerIndex
            controller = @_itemControllers.pop()
            controller.$el.slideUp duration:Duration.fast, complete:-> @remove()
