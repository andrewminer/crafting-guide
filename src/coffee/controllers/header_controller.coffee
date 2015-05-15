###
Crafting Guide - header_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

$                      = require 'jquery'
BaseController         = require './base_controller'
ItemSelectorController = require './item_selector_controller'
_                      = require 'underscore'
{Duration}             = require '../constants'
{Event}                = require '../constants'
{ProductionEnvs}       = require '../constants'
{Url}                  = require '../constants'

########################################################################################################################

module.exports = class HeaderController extends BaseController

    constructor: (options={})->
        if not options.client? then throw new Error 'options.client is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.storage? then throw new Error 'options.storage is required'
        super options

        @client  = options.client
        @modPack = options.modPack
        @storage = options.storage
        @_user   = options.user

    # Event Methods ################################################################################

    onLoginLinkClicked: (event)->
        event.preventDefault()

        if @user?
            @client.logout()
                .then =>
                    @storage.store 'loginSecurityToken', null
                    router.user = null
                .catch (error)->
                    logger.error -> "Failed to log out: #{error}"
                .done()
        else
            router.login()

    onLogoClicked: ->
        router.navigate '/', trigger:true
        return false

    onNavItemClicked: (event)->
        return true unless $(event.currentTarget).attr('href')?

        router.navigate $(event.currentTarget).attr('href'), trigger:true
        return false

    # Property Methods #############################################################################

    getUser: ->
        return @_user

    setUser: (user)->
        @_user = user
        @tryRefresh()

    Object.defineProperties @prototype,
        user: {get:@prototype.getUser, set:@prototype.setUser}

    # BaseController Overrides #####################################################################

    render: ->
        # Overriding render because the header is already part of the stock page layout, and we
        # don't need to replace it here.
        @_rendered = true

        @$navLinks = ($(el) for el in @$('.navBar a'))
        @$loginName = @$('.login .name')
        @$loginLink = @$('.login a')

        zIndex = @$navLinks.length + 100
        for $navLink in @$navLinks
            $navLink.css 'z-index', zIndex--

        if global.env in ProductionEnvs
            addThisUrl = 'http://s7.addthis.com/js/300/addthis_widget.js?pubid=ra-54f3c9717b2e530d'
            $('body').append "<script async=\"async\" src=\"#{addThisUrl}\"></script>"

        @_itemSelector = @addChild ItemSelectorController, '.view__item_selector.search',
            modPack:     @modPack
            onChoseItem: (itemSlug)=> @_goToItem(itemSlug)

    refresh: ->
        if @user?
            @$loginName.html "Hello #{router.user.login}!"
            @$loginLink.html "Logout"
        else
            @$loginName.html ''
            @$loginLink.html 'Login'

        for $navLink in @$navLinks
            linkPage = $navLink.data('page')
            if @model is linkPage
                $navLink.addClass 'selected'
            else
                $navLink.removeClass 'selected'

                if @model.indexOf(linkPage) isnt -1
                    $navLink.find('.dot').css 'opacity': 1;
                else
                    $navLink.find('.dot').css 'opacity': 0;

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.logo':    'onLogoClicked'
            'click .navBar a': 'onNavItemClicked'
            'click .login a':  'onLoginLinkClicked'

    # Private Methods ##############################################################################

    _goToItem: (itemSlug)->
        router.navigate Url.item(itemSlug:itemSlug.item, modSlug:itemSlug.mod), trigger:true
