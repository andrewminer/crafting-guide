#
# Crafting Guide - crafting_grid_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController = require "../../base_controller"
{Recipe}       = require("crafting-guide-common").models
SlotController = require "../slot/slot_controller"

########################################################################################################################

module.exports = class CraftingGridController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"
        options.templateName = "common/crafting_grid"
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

    # BaseController Methods #######################################################################

    onWillChangeModel: (oldModel, newModel)->
        if newModel? and (newModel.constructor isnt Recipe) then throw new Error "options.model must be a Recipe"
        super

    onDidRender: ->
        @_slotControllers = []
        for el in @$(".view__slot")
            controller = new SlotController el:el, imageLoader:@_imageLoader, modPack:@_modPack, router:@_router
            controller.render()
            @_slotControllers.push controller
        super

    refresh: ->
        index = 0
        for y in [0..2]
            for x in [0..2]
                controller = @_slotControllers[index++]
                if @model?
                    controller.model = @model.getInputAt x, y
                else
                    controller.model = null

        super
