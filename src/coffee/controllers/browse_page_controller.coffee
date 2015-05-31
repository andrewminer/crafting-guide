###
Crafting Guide - browse_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

AdsenseController = require './adsense_controller'
ModController     = require './mod_controller'
PageController    = require './page_controller'
{Duration}        = require '../constants'
{Event}           = require '../constants'
{Text}            = require '../constants'

########################################################################################################################

module.exports = class BrowsePageController extends PageController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'browse_page'
        super options

        @modPack = options.modPack
        @modPack.on Event.change, => @tryRefresh()

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return Text.browseDescription()

    getTitle: ->
        return 'Browse'

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense'
        @$modContainer     = @$('.mods')
        super

    refresh: ->
        @adsenseController.fillAdPositions()

        @_controllers ?= []
        controllerIndex = 0

        @modPack.eachMod (mod)=>
            return unless mod.enabled

            controller = @_controllers[controllerIndex]
            if not controller?
                controller = new ModController model:mod
                @_controllers.push controller
                controller.render()
                @$modContainer.append controller.$el
            else
                controller.model = mod

            controllerIndex += 1

        while @_controllers.length > controllerIndex
            @_controllers.pop().remove()

        super
