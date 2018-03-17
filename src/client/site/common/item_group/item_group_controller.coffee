#
# Crafting Guide - item_group_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'
ItemController = require './item_tile/item_tile_controller'

########################################################################################################################

module.exports = class ItemGroupController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        options.model        ?= []
        options.templateName  = 'common/item_group'
        options.title        ?= ''
        options.tagName       = 'section'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router
        @_title       = options.title

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        title:
            get: -> @_title

            set: (newTitle)->
                @_title = newTitle
                @tryRefresh()

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
                controller = new ItemController
                    imageLoader: @_imageLoader
                    model:       item
                    modPack:     @_modPack
                    router:      @_router
                @_itemControllers.push controller
                @$items.append controller.$el
                controller.render()
            else
                controller.model = item
            controllerIndex += 1

        while @_itemControllers.length > controllerIndex
            @_itemControllers.pop().remove()
