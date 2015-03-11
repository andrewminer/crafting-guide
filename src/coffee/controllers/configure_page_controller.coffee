###
Crafting Guide - configure_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

AdsenseController = require './adsense_controller'
PageController    = require './page_controller'
ModPackController = require './mod_pack_controller'

########################################################################################################################

module.exports = class ConfigurePageController extends PageController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.storage? then throw new Error 'options.storage is required'
        options.templateName  = 'configure_page'
        super options

        @modPack = options.modPack
        @storage = options.storage

    # PageController Overrides #####################################################################

    getTitle: ->
        return "Configure"

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'
        @modPackController = @addChild ModPackController, '.view__mod_pack', model:@modPack, storage:@storage
        super
