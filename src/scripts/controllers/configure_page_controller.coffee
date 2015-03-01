###
Crafting Guide - configure_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
ModPackController = require './mod_pack_controller'

########################################################################################################################

module.exports = class ConfigurePageController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.storage? then throw new Error 'options.storage is required'
        options.templateName  = 'configure_page'
        super options

        @modPack = options.modPack
        @storage = options.storage

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @modPackController = @addChild ModPackController, '.view__mod_pack', model:@modPack, storage:@storage
        super
