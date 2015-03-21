###
Crafting Guide - router.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BrowsePageController    = require './controllers/browse_page_controller'
ConfigurePageController = require './controllers/configure_page_controller'
CraftPageController     = require './controllers/craft_page_controller'
HeaderController        = require './controllers/header_controller'
HomePageController      = require './controllers/home_page_controller'
ImageLoader             = require './controllers/image_loader'
ItemPageController      = require './controllers/item_page_controller'
ItemSlug                = require './models/item_slug'
Mod                     = require './models/mod'
ModPack                 = require './models/mod_pack'
ModPageController       = require './controllers/mod_page_controller'
TutorialPageController  = require './controllers/tutorial_page_controller'
Storage                 = require './models/storage'
UrlParams               = require './url_params'
{ProductionEnvs}        = require './constants'
{DefaultMods}           = require './constants'
{Duration}              = require './constants'
{Event}                 = require './constants'
{Opacity}               = require './constants'
{Url}                   = require './constants'

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

        for modSlug, modData of DefaultMods
            mod = new Mod slug:modSlug
            mod.on Event.change + ':activeModVersion', makeResponder mod
            @storage.register "mod:#{mod.slug}", mod, 'activeVersion', modData.defaultVersion
            mod.fetch()

            @modPack.addMod mod

    # Backbone.Router Overrides ####################################################################

    navigate: ->
        super
        @_recordPageView()

    routes:
        '(/)':                                        'route__home'
        'browse(/)':                                  'route__browse'
        'browse/:modSlug(/)':                         'route__browseMod'
        'browse/:modSlug/:itemSlug(/)':               'route__browseModItem'
        'browse/:modSlug/tutorials/:tutorialSlug(/)': 'route__browseTutorial'
        'configure(/)':                               'route__configure'
        'craft(/)':                                   'route__craft'
        'craft/:text':                                'route__craft'

        'item/:itemSlug':         'deprecated__item'
        'crafting/(:text)':       'deprecated__crafting'
        'mod/:modSlug':           'deprecated__mod'
        'mod/:modSlug/:itemSlug': 'deprecated__modItem'

    # Route Methods ################################################################################

    route__home: ->
        params = new UrlParams recipeName:{type:'string'}, count:{type:'integer'}
        if params.recipeName?
            @deprecated__v1_root params
            return

        @_setPage 'home', new HomePageController _.extend {}, @_defaultOptions

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

    route__browseTutorial: (modSlug, tutorialSlug)->
        controller = new TutorialPageController _.extend {modSlug:modSlug, tutorialSlug:tutorialSlug}, @_defaultOptions
        @_setPage 'browseTutorial', controller

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
        controller = new ItemPageController _.extend {itemSlug:ItemSlug.slugify(itemSlug)}, @_defaultOptions
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
        switchToNextController = (event)=>
            logger.debug "show called: #{event}"
            @_resetGlobals()
            @_controller.unrender() if @_controller?

            @_page       = page
            @_controller = controller

            $pageContent = $('.page')
            $pageContent.attr 'class', 'page hideable hidden'

            window.scrollTo 0, 0

            controller.onWillShow()
            controller.$el = $pageContent
            controller.render()

        if @_controller?
            @_controller.hide -> switchToNextController()
        else
            switchToNextController()

    _resetGlobals: ->
        if global.env in ProductionEnvs
            for key, value of global
                if key.indexOf('google') isnt -1
                    delete global[key]

            delete global.adsByGoogle
            $('script[src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"]').remove()
            $('body').append('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>')
