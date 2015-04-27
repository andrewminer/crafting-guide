###
Crafting Guide - crafting_grid_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
ImageLoader    = require './image_loader'
SlotController = require './slot_controller'
{Duration}     = require '../constants'
{Event}        = require '../constants'

########################################################################################################################

module.exports = class CraftingGridController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        # options.model should be a recipe
        options.templateName = 'crafting_grid'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack

        @modPack.on Event.change, => @tryRefresh()

    # BaseController Methods #######################################################################

    onDidRender: ->
        @slotControllers = []
        for el in @$('.view__slot')
            controller = new SlotController el:el, imageLoader:@imageLoader, modPack:@modPack
            controller.render()
            @slotControllers.push controller
        super

    refresh: ->
        for i in [0...@slotControllers.length]
            controller = @slotControllers[i]
            controller.model = @model?.getStackAtSlot(i)

        super
