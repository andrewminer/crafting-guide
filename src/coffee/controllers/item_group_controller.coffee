###
Crafting Guide - item_group_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
Item           = require '../models/item'
ItemController = require './item_controller'
{Duration}     = require '../constants'
{Event}        = require '../constants'

########################################################################################################################

module.exports = class ItemGroupController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.model        ?= []
        options.title        ?= ''
        options.templateName  = 'item_group'
        super options

        @_imageLoader     = options.imageLoader
        @_modPack         = options.modPack
        @_title           = options.title

    # Property Methods #############################################################################

    getTitle: ->
        return @_title

    setTitle: (title)->
        @_title = title
        @tryRefresh()

    Object.defineProperties @prototype,
        title: {get:@prototype.getTitle, set:@prototype.setTitle}

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$title = @$('h2')
        @$items = @$('.panel')
        super

    onWillChangeModel: (oldModel, newModel)->
        newModel ?= []
        return super oldModel, newModel

    refresh: ->
        if @model.length > 0
            @$title.html @_title
            @_refreshItems()
            @show()
        else
            @hide()

        super

    # Private Methods ##############################################################################

    _refreshItems: ->
        @_itemControllers ?= []
        controllerIndex = 0

        for item in @model
            controller = @_itemControllers[controllerIndex]
            if not controller?
                controller = new ItemController imageLoader:@_imageLoader, model:item, modPack:@_modPack
                @_itemControllers.push controller
                @$items.append controller.$el
                controller.render()
            else
                controller.model = item
            controllerIndex += 1

        while @_itemControllers.length > controllerIndex
            @_itemControllers.pop().remove()
