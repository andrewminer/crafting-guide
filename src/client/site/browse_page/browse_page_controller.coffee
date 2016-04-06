#
# Crafting Guide - browse_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

AdsenseController = require '../common/adsense/adsense_controller'
ModTileController = require './mod_tile/mod_tile_controller'
PageController    = require '../page_controller'

########################################################################################################################

module.exports = class BrowsePageController extends PageController

    constructor: (options={})->
        if not options.modPack then throw new Error 'options.modPack is required'
        options.templateName = 'browse_page'
        super options

        @_modPack         = options.modPack
        @_tileControllers = []

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return c.text.browseDescription()

    getTitle: ->
        return "Browse"

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_adsenseController = @addChild AdsenseController, '.view__adsense', model:'skyscraper'

        @$tileContainer = @$('.tile_container')

    refresh: ->
        @_refreshModTiles()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshModTiles: ->
        index = 0
        mods = @_modPack.getAllMods()
        for mod in mods
            controller = @_tileControllers[index]
            if not controller
                controller = new ModTileController model:mod, router:@router
                controller.render()
                @$tileContainer.append controller.$el
                @_tileControllers.push controller
            else
                controller.model = mod
            index++

        while @_tileControllers.length > mods.length
            controller = @_tileControllers.pop()
            controller.remove()
