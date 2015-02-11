###
Crafting Guide - router.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###


CraftingPageController = require './controllers/crafting_page_controller'
{DefaultMods}          = require './constants'
{Duration}             = require './constants'
{Event}                = require './constants'
HeaderController       = require './controllers/header_controller'
ItemPageController     = require './controllers/item_page_controller'
Mod                    = require './models/mod'
ModPack                = require './models/mod_pack'
ModPageController      = require './controllers/mod_page_controller'
{Opacity}              = require './constants'
Storage                = require './models/storage'
{Url}                  = require './constants'
UrlParams              = require './url_params'

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
        '':                       'root'
        'item/:itemSlug':         'item'
        'crafting/(:text)':       'crafting'
        'mod/:modSlug':           'mod'
        'mod/:modSlug/:itemSlug': 'modItem'

    # Route Methods ################################################################################

    crafting: (text)->
        controller = new CraftingPageController _.extend {}, @_defaultOptions
        controller.model.params = inventoryText:text
        @_setPage 'crafting', controller

    item: (itemSlug)->
        controller = new ItemPageController _.extend {itemSlug:itemSlug}, @_defaultOptions
        @_setPage 'item', controller

    modItem: (modSlug, itemSlug)->
        slug = _.composeSlugs modSlug, itemSlug
        controller = new ItemPageController _.extend {itemSlug:slug}, @_defaultOptions
        @_setPage 'item', controller

    mod: (slug)->
        controller = new ModPageController  _.extend {}, @_defaultOptions
        controller.model = @modPack.getMod slug
        @_setPage 'mod', controller

    root: ->
        params = new UrlParams recipeName:{type:'string'}, count:{type:'integer'}

        text = ''
        if params.recipeName?
            if params.count?
                text = "#{params.count}.#{_.slugify(params.recipeName)}"
            else
                text = _.slugify params.recipeName

        @navigate Url.crafting(inventoryText:text), trigger:true

    # Private Methods ##############################################################################

    _recordPageView: ->
        pathname = window.location.pathname

        if global.env is 'production' and ga?
            logger.info -> "Recording GA page view: #{pathname}"
            ga 'send', 'pageview', pathname
        else
            logger.info -> "Suppressing GA page view: #{pathname}"

    _setPage: (page, controller)->
        return if @_controller is controller

        logger.info -> "changing to page controller: #{controller.constructor.name}"
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
            showDuration = Duration.long
            @_controller.$el.fadeOut showDuration, show
        else
            show()
