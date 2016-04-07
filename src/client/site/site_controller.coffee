#
# Crafting Guide - site_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController     = require './base_controller'
FeedbackController = require './feedback/feedback_controller'
FooterController   = require './footer/footer_controller'
GitHubUser         = require '../models/site/github_user'
HeaderController   = require './header/header_controller'
ImageLoader        = require './image_loader'
Mod                = require '../models/game/mod'
ModPack            = require '../models/game/mod_pack'
Router             = require './router'

########################################################################################################################

module.exports = class SiteController extends BaseController

    constructor: (options={})->
        if not options.client? then throw new Error 'options.client is required'
        if not options.storage? then throw new Error 'options.storage is required'
        options.el = 'html'
        super options

        @client      = options.client
        @imageLoader = new ImageLoader defaultUrl:'/images/unknown.png'
        @modPack     = new ModPack
        @router      = new Router this
        @storage     = options.storage

        @_currentPage           = null
        @_currentPageController = null
        @_user                  = null

    # Public Methods ###############################################################################

    loadDefaultModPack: ->
        makeResponder = (m)-> return ->
            m.activeModVersion.fetch() if m.activeModVersion?

        for modSlug, modData of c.defaultMods
            mod = new Mod slug:modSlug
            mod.on c.event.change + ':activeModVersion', makeResponder mod
            @storage.register "mod:#{mod.slug}", mod, 'activeVersion', modData.defaultVersion
            mod.fetch()

            @modPack.addMod mod

        if global.env isnt 'prerender'
            @modPack.once c.event.sync, =>
                @$pageContent.css 'display', ''
                @$pageContentLoading.css 'display', 'none'

    loadCurrentUser: ->
        @client.fetchCurrentUser()
            .then (response)=>
                userData = response.json?.data?.user
                @user = new GitHubUser userData if userData?
            .catch (error)=>
                if error?.response?.statusCode isnt 401
                    logger.error "Failed to get current user: #{error}"
                else
                    logger.info "User is not logged in"
            .done()

    login: ->
        @storage.store 'post-login-url', window.location.pathname
        @router.navigate c.url.login(), trigger:true

    logout: ->
        @storage.store 'loginSecurityToken', null
        @user = null
        @client.logout()
            .catch (error)->
                logger.error -> "Failed to log out: #{error}"
            .done()

    resumeAfterLogin: ->
        url = @storage.load 'post-login-url'
        url = if (not url? or url is 'null') then null else url
        if url? then @router.navigate url, trigger:true
        @storage.store 'post-login-url', null

    # Property Methods #############################################################################

    getControllerOptions: ->
        client:        @client
        imageLoader:   @imageLoader
        modPack:       @modPack
        router:        @router
        storage:       @storage
        enterFeedback: (message)=> @_feedbackController.enterFeedback(message)
        user:          @user

    getUser: ->
        return @_user

    setUser: (newUser)->
        oldUser = @_user
        return if newUser is oldUser

        @_user = newUser
        logger.info -> "User changed to: #{newUser?.name}"

        @trigger c.event.change + ':user', this, oldUser, newUser
        @trigger c.event.change, this

        if @_currentPageController? then @_currentPageController.user = newUser

    Object.defineProperties @prototype,
        controllerOptions: { get:@::getControllerOptions }
        user: { get:@::getUser, set:@::setUser }

    # BaseController Overrides #####################################################################

    render: ->
        @_footerController = @addChild FooterController, '.view__footer', @controllerOptions
        @_headerController = @addChild HeaderController, '.view__header', @controllerOptions

        @$pageContent = @$('.page > .content')
        @$pageContentLoading = @$('.page > .content-loading')

        @_feedbackController = @addChild FeedbackController, '.view__feedback'

    # Private Methods ##############################################################################

    setPage: (page, controller)->
        return if @_currentPageController is controller

        logger.info -> "changing to page controller: #{controller.constructor.name}"

        if @_currentPageController
            @_currentPageController.unrender()
        @_resetGlobals()

        @_currentPage           = page
        @_currentPageController = controller

        $pageContent = $('.page > .content')
        $pageContent.removeClass()
        $pageContent.addClass 'content'

        window.scrollTo 0, 0

        @_headerController.model = controller: controller

        @_currentPageController.user = @user
        @_currentPageController.onWillShow()
        @_currentPageController.$el = $pageContent
        @_currentPageController.render()

    _resetGlobals: ->
        if global.env in c.productionEnvs
            for key, value of global
                if key.indexOf('google') isnt -1
                    delete global[key]

            delete global.adsByGoogle
            $('script[src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"]').remove()
            $('body').append('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>')
