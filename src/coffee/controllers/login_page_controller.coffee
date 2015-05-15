###
Crafting Guide - login_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

PageController        = require './page_controller'
User                  = require '../models/user'
_                     = require 'underscore'
{CraftingGuideClient} = require 'crafting-guide-common'
{Event}               = require '../constants'
{Login}               = require '../constants'
{Url}                 = require '../constants'

########################################################################################################################

module.exports = class LoginPageController extends PageController

    @State: State =
        ReadyToLogin:    'ready-to-login'
        ServerDown:      'server-down'
        InvalidCallback: 'invalid-callback'
        FetchingToken:   'fetching-token'
        LoggedIn:        'logged-in'

    constructor: (options={})->
        options.templateName = 'login_page'

        @client  = options.client
        @params  = options.params
        @storage = options.storage

        @_accessTokenLookupFailed = false

        @client.on Event.change + ':status', => @tryRefresh()

        super options

    # Event Methods ################################################################################

    onExpandReadMore: (event)->
        event.preventDefault()
        @$readMoreLink.addClass 'hidden'
        @$readMoreContent.removeClass 'closed'

    onLoginButtonClicked: (event)->
        event.preventDefault()
        @_redirectToGitHub()

    # Property Methods #############################################################################

    getLoginSecurityToken: ->
        @storage.load 'loginSecurityToken'

    setLoginSecurityToken: (value)->
        @storage.store 'loginSecurityToken', value

    Object.defineProperties @prototype,
        loginSecurityToken: {get:@prototype.getLoginSecurityToken, set:@prototype.setLoginSecurityToken}
        serverStatus:       {get:@prototype.getServerStatus,       set:@prototype.setServerStatus}

    # PageController Overrides #####################################################################

    getTitle: ->
        return "Login"

    # BaseController Methods #######################################################################

    onDidRender: ->
        @$readMoreLink    = @$('a.read-more')
        @$readMoreContent = @$('.read-more-content')

        if (not @user?) and (@params?.state?) and (@params?.state is @loginSecurityToken)
            @client.completeGitHubLogin code:@params.code
                .then (response)=>
                    attributes = response.json.data.user
                    if attributes?
                        router.user = new User attributes
                        router.resumeAfterLogin()
                .catch (error)=>
                    logger.error "Failed to get access token: #{error}"
                    @_accessTokenLookupFailed = true
                    @refresh()
                .done()
        super

    refresh: ->
        state = @_computeState()
        @$('.two-thirds-content').addClass 'hidden'
        @$(".two-thirds-content.#{state}").removeClass 'hidden'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.read-more': 'onExpandReadMore'
            'click button': 'onLoginButtonClicked'

    # Private Methods ##############################################################################

    _computeState: ->
        if @user? then return State.LoggedIn

        if @client.status is CraftingGuideClient.Status.Down then return State.ServerDown

        if @_accessTokenLookupFailed then return State.InvalidCallback

        if @params?.state?
            if @params.state is @loginSecurityToken
                return State.FetchingToken
            else
                return State.InvalidCallback

        return State.ReadyToLogin

    _compeleteLogin: (code)->
        @client.completeGitHubLogin code:code
            .then (response)=>
                router.user = new User response.json.user
            .catch (error)=>
                @_accessTokenLookupFailed = true
                @refresh()
            .done()

    _redirectToGitHub: ->
        @loginSecurityToken = _.uuid()
        clientId = Login.clientIds[global.env]
        window.location.href = Login.authorizeUrl clientId:clientId, state:@loginSecurityToken
