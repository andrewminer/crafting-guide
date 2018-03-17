#
# Crafting Guide - login_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

PageController        = require '../page_controller'
GitHubUser            = require '../../models/site/github_user'
{CraftingGuideClient} = require 'crafting-guide-common'

########################################################################################################################

module.exports = class LoginPageController extends PageController

    @::State =
        ReadyToLogin:    'ready-to-login'
        ServerDown:      'server-down'
        InvalidCallback: 'invalid-callback'
        FetchingToken:   'fetching-token'
        LoggedIn:        'logged-in'

    constructor: (options={})->
        options.templateName = 'login_page'

        @_client  = options.client
        @_params  = options.params
        @_storage = options.storage

        @_accessTokenLookupFailed = false

        @_client.on c.event.change + ':status', => @tryRefresh()

        super options

    # Event Methods ################################################################################

    onExpandReadMore: (event)->
        @$readMoreLink.css display: 'none'
        @$readMoreContainer.css 'max-height':@$readMoreContent.height()
        return false

    onLoginButtonClicked: (event)->
        @_redirectToGitHub()
        return false

    onLogoutButtonClicked: (event)->
        global.site.logout()
        return false

    # Property Methods #############################################################################

    getLoginSecurityToken: ->
        @_storage.load 'loginSecurityToken'

    setLoginSecurityToken: (value)->
        @_storage.store 'loginSecurityToken', value

    Object.defineProperties @prototype,
        loginSecurityToken: {get:@prototype.getLoginSecurityToken, set:@prototype.setLoginSecurityToken}

    # PageController Overrides #####################################################################

    getTitle: ->
        return "Login"

    # BaseController Methods #######################################################################

    onDidRender: ->
        @$readMoreContainer = @$('.expandable-container.read-more')
        @$readMoreContent   = @$('.read-more .content')
        @$readMoreLink      = @$('a.read-more')
        @$redirectMessage   = @$('.withRedirect')
        @$userAvatar        = @$('.user img')
        @$userEmail         = @$('.user .email')
        @$userName          = @$('.user .name')

        if (not @user?) and (@_params?.state?) and (@_params?.state is @loginSecurityToken)
            @_client.completeGitHubLogin code:@_params.code
                .then (response)=>
                    attributes = response.json.data.user
                    if attributes?
                        global.site.user = new GitHubUser attributes
                        global.site.resumeAfterLogin()
                .catch (error)=>
                    logger.error "Failed to get access token: #{error}"
                    @_accessTokenLookupFailed = true
                    @refresh()
                .done()
        super

    refresh: ->
        state = @_computeState()
        @$el.find('> *').css display: 'none'
        @$(".#{state}").css display: ''

        if state is @State.LoggedIn
            @$userAvatar.attr 'src', @user.avatarUrl
            @$userEmail.text @user.email
            @$userName.text @user.name

            postLoginUrl = @_storage.load 'post-login-url'
            @$redirectMessage.css display:(if postLoginUrl? then 'none' else '')

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.read-more':    'onExpandReadMore'
            'click .button.login':  'onLoginButtonClicked'
            'click .button.logout': 'onLogoutButtonClicked'

    # Private Methods ##############################################################################

    _computeState: ->
        if @user? then return @State.LoggedIn

        if @_client.status is CraftingGuideClient.Status.Down then return @State.ServerDown

        if @_accessTokenLookupFailed then return @State.InvalidCallback

        if @_params?.state?
            if @_params.state is @loginSecurityToken
                return @State.FetchingToken
            else
                return @State.InvalidCallback

        return @State.ReadyToLogin

    _compeleteLogin: (code)->
        @_client.completeGitHubLogin code:code
            .then (response)=>
                global.site.user = new GitHubUser response.json
            .catch (error)=>
                @_accessTokenLookupFailed = true
                @refresh()
            .done()

    _redirectToGitHub: ->
        @loginSecurityToken = _.uuid()
        clientId = c.login.clientIds[global.env]
        window.location.href = c.login.authorizeUrl clientId:clientId, state:@loginSecurityToken
