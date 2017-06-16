#
# Crafting Guide - site_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

AdsenseController  = require './common/adsense/adsense_controller'
BaseController     = require './base_controller'
c                  = require "../../common/constants"
FeedbackController = require './feedback/feedback_controller'
FileCache          = require '../models/site/file_cache'
FooterController   = require './footer/footer_controller'
GitHubUser         = require '../models/site/github_user'
HeaderController   = require './header/header_controller'
ImageLoader        = require './image_loader'
{Mod}              = require('crafting-guide-common').deprecated.game
{ModPack}          = require('crafting-guide-common').deprecated.game
Router             = require './router'

########################################################################################################################

module.exports = class SiteController extends BaseController

    constructor: (options={})->
        if not options.client? then throw new Error 'options.client is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.storage? then throw new Error 'options.storage is required'
        options.el = 'html'
        super options

        @client      = options.client
        @imageLoader = new ImageLoader defaultUrl:'/images/unknown.png'
        @modPack     = options.modPack
        @router      = new Router this
        @storage     = options.storage

        @_adsenseController     = new AdsenseController
        @_currentPage           = null
        @_currentPageController = null
        @_user                  = null

    # Public Methods ###############################################################################

    loadCurrentUser: ->
        @client.getCurrentUser()
            .then (response)=>
                userData = response.json
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
        @client.deleteSession()
            .catch (error)->
                logger.error -> "Failed to log out: #{error}"
            .done()

    resumeAfterLogin: ->
        url = @storage.load 'post-login-url'
        url = if (not url? or url is 'null') then null else url + '?login=true'
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

        if global.env isnt "prerender"
            @$pageContent.removeClass "hidden"
            @$pageContentLoading.addClass "hidden"

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
        $pageContent.css display:''
        if not @$pageContentLoading.hasClass 'hidden'
            $pageContent.addClass 'hidden'

        window.scrollTo 0, 0

        @_headerController.model = controller: controller, page: page

        @_currentPageController.user = @user
        @_currentPageController.onWillShow()
        @_currentPageController.$el = $pageContent
        @_currentPageController.render()

        @_adsenseController.reset()

    _resetGlobals: ->
        if global.env in c.productionEnvs
            for key, value of global
                if key.indexOf('google') isnt -1
                    delete global[key]

            delete global.adsByGoogle
            $('script[src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"]').remove()
            $('body').append('<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>')
