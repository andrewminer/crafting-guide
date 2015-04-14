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
LoginPageController     = require './controllers/login_page_controller'
Mod                     = require './models/mod'
ModPack                 = require './models/mod_pack'
ModPageController       = require './controllers/mod_page_controller'
TutorialPageController  = require './controllers/tutorial_page_controller'
Storage                 = require './models/storage'
UrlParams               = require './url_params'
User                    = require './models/user'
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
        @_user            = null
        super options

        @client      = options.client
        @imageLoader = new ImageLoader defaultUrl:'/images/unknown.png'
        @modPack     = new ModPack
        @storage     = new Storage storage:window.localStorage

        @_defaultOptions = client:@client, imageLoader:@imageLoader, modPack:@modPack, storage:@storage, user:@_user
        @on Event.change + ':user', => @_defaultOptions.user = @_user

        @headerController = new HeaderController _.extend {el:'.view__header'}, @_defaultOptions
        @headerController.render()
        @on Event.change + ':user', => @headerController.user = @user

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

    loadCurrentUser: ->
        @client.fetchCurrentUser()
            .then (response)=>
                userData = response.json?.data?.user
                @user = new User userData if userData?
            .catch (error)=>
                if error.response.statusCode isnt 401
                    logger.error "Failed to get current user: #{error}"
                else
                    logger.info "User is not logged in"
            .done()

    # Property Methods #############################################################################

    getUser: ->
        return @_user

    setUser: (newUser)->
        oldUser = @_user
        return if newUser is oldUser

        @_user = newUser
        logger.info -> "User changed to: #{newUser}"

        @trigger Event.change + ':user', this, oldUser, newUser
        @trigger Event.change, this

        if @_controller? then @_controller.user = newUser

    Object.defineProperties @prototype,
        user: {get:@prototype.getUser, set:@prototype.setUser}

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
        'login(/)':                                   'route__login'

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

    route__login: ->
        params = new UrlParams code:{type:'string'}, state:{type:'string'}
        controller = new LoginPageController _.extend {params:params}, @_defaultOptions
        @_setPage 'login', controller

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
            @_controller.unrender() if @_controller?
            @_resetGlobals()

            @_page       = page
            @_controller = controller

            $pageContent = $('.page')
            $pageContent.attr 'class', 'page hideable hidden'

            window.scrollTo 0, 0

            controller.user = @user
            controller.onWillShow()
            controller.$el = $pageContent
            controller.render()
            controller.show()

        if @_controller?
            @_controller.once Event.animate.hide.finish, switchToNextController
            @_controller.hide()
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
