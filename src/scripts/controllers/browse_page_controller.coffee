###
Crafting Guide - browse_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

PageController = require './page_controller'
{Duration}     = require '../constants'
{Event}        = require '../constants'
ModController  = require './mod_controller'

########################################################################################################################

module.exports = class BrowsePageController extends PageController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'browse_page'
        super options

        @modPack = options.modPack
        @modPack.on Event.change, => @tryRefresh()

    # PageController Overrides #####################################################################

    getTitle: ->
        return 'Browse'

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$modContainer = @$('.mods')
        super

    refresh: ->
        @_controllers ?= []
        controllerIndex = 0

        @modPack.eachMod (mod)=>
            return unless mod.enabled

            controller = @_controllers[controllerIndex]
            if not controller?
                controller = new ModController model:mod
                controller.render()
                @$modContainer.append controller.$el
            else
                controller.model = mod

            controllerIndex += 1

        while @_controllers.length > controllerIndex
            controller = @_controllers.pop()
            controller.$el.addClass 'removing'
            controller.$el.one Event.transitionEnd -> controller.$el.remove()

        super
