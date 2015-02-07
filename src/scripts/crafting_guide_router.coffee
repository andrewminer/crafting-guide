###
Crafting Guide - router.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

{DefaultMods}          = require './constants'
{Duration}             = require './constants'
{Event}                = require './constants'
HeaderController       = require './controllers/header_controller'
CraftingPageController = require './controllers/crafting_page_controller'
Mod                    = require './models/mod'
ModPack                = require './models/mod_pack'
ModPageController      = require './controllers/mod_page_controller'
{Opacity}              = require './constants'
Storage                = require './models/storage'
UrlParams              = require './url_params'
{Url}                  = require './constants'

########################################################################################################################

module.exports = class CraftingGuideRouter extends Backbone.Router

    constructor: (options={})->
        @_page            = null
        @_pageControllers = {}
        @_lastReported    = null
        super options

        @modPack = new ModPack
        @storage = new Storage storage:window.localStorage
        @_defaultOptions = modPack:@modPack, storage:@storage

        @headerController = new HeaderController el:'.view__header'

    # Public Methods ###############################################################################

    loadDefaultModPack: ->
        makeResponder = (m)-> return ->
            m.activeModVersion.fetch() if m.activeModVersion?

        for slug in DefaultMods
            mod = new Mod slug:slug
            mod.on Event.change + ':activeModVersion', makeResponder mod
            @storage.register "mod:#{mod.slug}", mod, 'activeVersion'
            mod.fetch()

            @modPack.addMod mod

    # Backbone.Router Overrides ####################################################################

    navigate: ->
        super
        @_recordPageView()

    routes:
        '':                          'root'
        'item/(:inventoryText)':     'crafting'
        'crafting/(:inventoryText)': 'crafting'
        'mod/:slug':                 'mod'

    # Route Methods ################################################################################

    root: ->
        params = new UrlParams recipeName:{type:'string'}, count:{type:'integer'}

        text = ''
        if params.recipeName?
            if params.count?
                text = "#{params.count}:#{params.recipeName}"
            else
                text = "#{params.recipeName}"

        @navigate Url.crafting(inventoryText:text), trigger:true

    crafting: (inventoryText)->
        controller = new CraftingPageController @_defaultOptions
        controller.model.params = inventoryText:inventoryText
        @_setPage 'crafting', controller

    mod: (slug)->
        controller = new ModPageController @_defaultOptions
        controller.model = @modPack.getMod slug
        @_setPage 'mod', controller

    # Private Methods ##############################################################################

    _recordPageView: ->
        pathname = window.location.pathname

        if global.env is 'production' and ga?
            logger.info "Recording GA page view: #{pathname}"
            ga 'send', 'pageview', pathname
        else
            logger.info "Suppressing GA page view: #{pathname}"

    _setPage: (page, controller)->
        return if @_page is page

        logger.info "changing to #{page} page"
        showDuration = Duration.normal
        show = =>
            @_page       = page
            @_controller = controller

            controller.onWillShow()
            controller.render()

            $pageContent = $('.page')
            controller.$el.addClass 'page'
            $pageContent.replaceWith controller.$el

            controller.$el.fadeIn showDuration, ->
                controller.onDidShow()

        if @_controller?
            showDuration = Duration.fast
            @_controller.$el.fadeOut showDuration, show
        else
            show()
