###
Crafting Guide - router.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###


BrowsePageController    = require './controllers/browse_page_controller'
CraftPageController  = require './controllers/craft_page_controller'
ConfigurePageController = require './controllers/configure_page_controller'
{DefaultMods}           = require './constants'
{Duration}              = require './constants'
{Event}                 = require './constants'
HeaderController        = require './controllers/header_controller'
ItemPageController      = require './controllers/item_page_controller'
ItemSlug                = require './models/item_slug'
ImageLoader             = require './controllers/image_loader'
Mod                     = require './models/mod'
ModPack                 = require './models/mod_pack'
ModPageController       = require './controllers/mod_page_controller'
{Opacity}               = require './constants'
Storage                 = require './models/storage'
{Url}                   = require './constants'
UrlParams               = require './url_params'
WhatsNewPageController  = require './controllers/whats_new_page_controller'

########################################################################################################################

module.exports = class CraftingGuideRouter extends Backbone.Router

    constructor: (options={})->
        @_page            = null
        @_pageControllers = {}
        @_lastReported    = null
        super options

        @imageLoader     = new ImageLoader defaultUrl:'/images/unknown.png'
        @modPack         = new ModPack
        @storage         = new Storage storage:window.localStorage
        @_defaultOptions = imageLoader:@imageLoader, modPack:@modPack, storage:@storage

        @headerController = new HeaderController el:'.view__header'
        @headerController.render()

    # Public Methods ###############################################################################

    loadDefaultModPack: ->
        makeResponder = (m)-> return ->
            m.activeModVersion.fetch() if m.activeModVersion?

        for modSlug in DefaultMods
            mod = new Mod slug:modSlug
            mod.on Event.change + ':activeModVersion', makeResponder mod
            @storage.register "mod:#{mod.slug}", mod, 'activeVersion'
            mod.fetch()

            @modPack.addMod mod

    # Backbone.Router Overrides ####################################################################

    navigate: ->
        super
        @_recordPageView()

    routes:
        '':                          'route__whats_new'
        'browse':                    'route__browse'
        'browse/:modSlug':           'route__browseMod'
        'browse/:modSlug/:itemSlug': 'route__browseModItem'
        'configure':                 'route__configure'
        'craft(/:text)':             'route__craft'

        'item/:itemSlug':         'deprecated__item'
        'crafting/(:text)':       'deprecated__crafting'
        'mod/:modSlug':           'deprecated__mod'
        'mod/:modSlug/:itemSlug': 'deprecated__modItem'

    # Route Methods ################################################################################

    route__whats_new: ->
        params = new UrlParams recipeName:{type:'string'}, count:{type:'integer'}
        if params.recipeName?
            @deprecated__v1_root params
            return

        @_setPage 'whats_new', new WhatsNewPageController _.extend {}, @_defaultOptions

    route__browse: ->
        @_setPage 'browse', new BrowsePageController _.extend {}, @_defaultOptions

    route__browseMod: (modSlug)->
        controller = new ModPageController  _.extend {}, @_defaultOptions
        controller.model = @modPack.getMod modSlug
        @_setPage 'browseMod', controller

    route__browseModItem: (modSlug, itemSlug)->
        slug = new ItemSlug modSlug, itemSlug
        controller = new ItemPageController _.extend {itemSlug:slug}, @_defaultOptions
        @_setPage 'browseModItem', controller

    route__configure: ->
        @_setPage 'configure', new ConfigurePageController _.extend {}, @_defaultOptions

    route__craft: (text)->
        controller = new CraftPageController _.extend {}, @_defaultOptions
        controller.model.params = inventoryText:text
        @_setPage 'craft', controller

    # Deprecated Route Methods #####################################################################

    deprecated__crafting: (text)->
        controller = new CraftPageController _.extend {}, @_defaultOptions
        controller.model.params = inventoryText:text
        @_setPage 'crafting', controller

    deprecated__item: (itemSlug)->
        controller = new ItemPageController _.extend {itemSlug:itemSlug}, @_defaultOptions
        @_setPage 'item', controller

    deprecated__modItem: (modSlug, itemSlug)->
        slug = new ItemSlug modSlug, itemSlug
        controller = new ItemPageController _.extend {itemSlug:slug}, @_defaultOptions
        @_setPage 'item', controller

    deprecated__mod: (modSlug)->
        controller = new ModPageController  _.extend {}, @_defaultOptions
        controller.model = @modPack.getMod modSlug
        @_setPage 'mod', controller

    deprecated__v1_root: (params)->
        text = ''
        if params.recipeName?
            if params.count? and params.count > 1
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
        @headerController.model = page

        showDuration = Duration.normal
        show = =>
            @_page       = page
            @_controller = controller

            controller.onWillShow()
            controller.render()

            $pageContent = $('.page')
            controller.$el.addClass 'page'
            $pageContent.replaceWith controller.$el

            controller.$el.slideDown showDuration, ->
                controller.onDidShow()

        if @_controller?
            showDuration = showDuration / 2
            @_controller.$el.slideUp showDuration, show
        else
            show()
