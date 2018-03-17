#
# Crafting Guide - suggest_mod_panel_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../../base_controller'
EmailClient    = require '../../../../models/site/email_client'

########################################################################################################################

module.exports = class SuggestModPanelController extends BaseController

    constructor: (options={})->
        options.templateName = 'browse_page/mod_ballot/suggest_mod_panel'
        super options

        @_emailClient = new EmailClient

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        isFormComplete:
            get: ->
                return false unless @name.length > 0
                return false unless @url.length > 0
                return true

        name:
            get: ->
                return '' unless @rendered
                return @$nameField.val()

        url:
            get: ->
                return '' unless @rendered
                return @$urlField.val()

        user:
            get: -> @_user
            set: (user)-> @_user = user

    # Event Methods ################################################################################

    onButtonClicked: (event)->
        return false unless @isFormComplete

        tracker.trackEvent c.tracking.category.feedback, 'suggest-mod', @name
        @_sendRequest()
        return false

    onNameChanged: (event)->
        @refresh()
        return false

    onUrlChanged: (event)->
        @refresh()
        return false

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$button       = @$('.button')
        @$errorPanel   = @$('.error')
        @$initialPanel = @$('.initial')
        @$nameField    = @$('input.name')
        @$sendingPanel = @$('.sending')
        @$successPanel = @$('.success')
        @$urlField     = @$('input.url')

        @hide @$errorPanel
        @hide @$successPanel
        @hide @$sendingPanel
        super

    refresh: ->
        @_refreshButtonState()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'input .name':   'onNameChanged'
            'input .url':    'onUrlChanged'
            'click .button': 'onButtonClicked'

    # Private Methods ##############################################################################

    _refreshButtonState: ->
        if @isFormComplete
            @$button.removeClass 'disabled'
        else
            @$button.addClass 'disabled'

    _sendRequest: ->
        showPanel = ($selectedPanel)=>
            @hide $panel for $panel in [@$initialPanel, @$sendingPanel, @$successPanel, @$errorPanel]
            @show $selectedPanel

        data =
            name:  @name
            url:   @url
            user:  @user?.name
            email: @user?.email

        showPanel @$sendingPanel
        w(@_emailClient.send 'mod-suggestion', name:@name, url:@url)
            .then =>
                showPanel @$successPanel
                @$urlField.val ""
                @$nameField.val ""
                @refresh()
            .catch => showPanel @$errorPanel
            .delay c.duration.slow * 2
            .then => showPanel @$initialPanel
