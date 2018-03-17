#
# Crafting Guide - crafting_grid_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'
SlotController = require '../slot/slot_controller'

########################################################################################################################

module.exports = class CraftingGridController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        # options.model should be a recipe
        options.templateName = 'common/crafting_grid'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

        @_modPack.on c.event.change, => @tryRefresh()

    # BaseController Methods #######################################################################

    onDidRender: ->
        @_slotControllers = []
        for el in @$('.view__slot')
            controller = new SlotController el:el, imageLoader:@_imageLoader, modPack:@_modPack, router:@_router
            controller.render()
            @_slotControllers.push controller
        super

    refresh: ->
        for controller, index in @_slotControllers
            controller.model = @model?.getStackAtSlot(index)

        super
