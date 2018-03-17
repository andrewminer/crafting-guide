#
# Crafting Guide - browse_page_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{CraftingGuideClient} = require('crafting-guide-common').api
ModBallotController   = require './mod_ballot/mod_ballot_controller'
ModTileController     = require './mod_tile/mod_tile_controller'
PageController        = require '../page_controller'

########################################################################################################################

module.exports = class BrowsePageController extends PageController

    constructor: (options={})->
        if not options.client      then throw new Error 'options.client is required'
        if not options.imageLoader then throw new Error 'options.imageLoader is required'
        if not options.modPack     then throw new Error 'options.modPack is required'

        options.templateName = 'browse_page'
        super options

        @_client          = options.client
        @_imageLoader     = options.imageLoader
        @_modPack         = options.modPack
        @_tileControllers = []

        @_client.on c.event.change, => @tryRefresh()

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        user:
            get: -> @_user

            set: (newUser)->
                @_user = newUser
                @tryRefresh()

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return c.text.browseDescription()

    getTitle: ->
        return "Browse"

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_modBallotController = @addChild ModBallotController, '.view__mod_ballot',
            client:      @_client
            imageLoader: @_imageLoader
            user:        @_user

        @$tileContainer = @$('.tile_container')

    refresh: ->
        @_modBallotController.user = @user
        @_refreshModTiles()
        @_refreshBallot()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshBallot: ->
        if @_client.status is CraftingGuideClient.Status.Down
            @_modBallotController.hide()
        else
            @_modBallotController.show()

    _refreshModTiles: ->
        index = 0
        mods = (mod for modId, mod of @_modPack.mods)
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
