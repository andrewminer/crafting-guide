###
Crafting Guide - login_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

PageController = require './page_controller'
{Login}        = require '../constants'

########################################################################################################################

module.exports = class LoginPageController extends PageController

    @ServerStatus:
        Up: 'up'
        Down: 'down'

    constructor: (options={})->
        options.templateName = 'login_page'
        super options

        @client  = options.client
        @storage = options.storage

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

    getServerStatus: ->
        return @_serverStatus

    setServerStatus: (serverStatus)->
        @_serverStatus = serverStatus
        @tryRefresh()

    Object.defineProperties @prototype,
        loginSecurityToken: {get:@prototype.getLoginSecurityToken, set:@prototype.setLoginSecurityToken}
        serverStatus:       {get:@prototype.getServerStatus,       set:@prototype.setServerStatus}

    # PageController Overrides #####################################################################

    getTitle: ->
        return "Login"

    # BaseController Methods #######################################################################

    onWillRender: ->
        @_validateServerStatus()
        super

    onDidRender: ->
        @$readMoreLink       = @$('a.read-more')
        @$readMoreContent    = @$('.read-more-content')
        @$serviceUpContent   = @$('.service-up')
        @$serviceDownContent = @$('.service-down')
        super

    refresh: ->
        if @serverStatus is LoginPageController.ServerStatus.Down
            @$serviceUpContent.addClass 'hidden'
            @$serviceDownContent.removeClass 'hidden'
        else
            @$serviceUpContent.removeClass 'hidden'
            @$serviceDownContent.addClass 'hidden'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.read-more': 'onExpandReadMore'
            'click button': 'onLoginButtonClicked'

    # Private Methods ##############################################################################

    _redirectToGitHub: ->
        @loginSecurityToken = _.uuid()
        baseUrl = Login.authorizeUrl state:@loginSecurityToken
        window.location.href = baseUrl

    _validateServerStatus: ->
        message = _.uuid()
        logger.info "Checking Crafting Guide Server at #{@client.baseUrl}..."
        @client.ping message:message
            .then (response)=>
                if response.json.message is message
                    @serverStatus = LoginPageController.ServerStatus.Up
                    logger.info "Crafting Guide Server is up"
                else
                    throw new Error "Invalid server ping response: #{response.json.message} isnt #{message}"
            .catch (error)=>
                @serverStatus = LoginPageController.ServerStatus.Down
                logger.error "Crafting Guide server is down: #{error}"
