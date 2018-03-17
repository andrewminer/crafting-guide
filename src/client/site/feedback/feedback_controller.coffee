#
# Crafting Guide - feedback_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController = require '../base_controller'
EmailClient    = require '../../models/site/email_client'
w              = require "when"

########################################################################################################################

module.exports = class FeedbackController extends BaseController

    constructor: (options={})->
        options.model ?= new EmailClient
        options.templateName = 'feedback'
        super options

        Object.defineProperty this, 'isOpen', get:-> @$el.offset().left is 0

    # Public Methods ###############################################################################

    enterFeedback: (message)->
        tracker.trackEvent c.tracking.category.feedback, 'ask-a-question'
        promise = w(true)
        if not @isOpen then promise = @onToggle()
        promise.then => @$commentField.val message

    # Event Methods ################################################################################

    onSendClicked: ->
        return unless @$commentField.val().length > 0
        @$sendButton.addClass 'disabled'

        message =
            url: window.location.href
            name: @$nameField.val()
            email: @$emailField.val()
            comment: @$commentField.val()

        tracker.trackEvent c.tracking.category.feedback, 'send'
        @model.send('feedback', message)
            .then =>
                @onToggle()
                @$error.css display: 'none'
            .catch (error)=>
                @$error.css display: ''
            .then =>
                @$sendButton.removeClass 'disabled'

    onTextChanged: (event)->
        if @$commentField.val().length > 0
            @$sendButton.removeClass 'disabled'
        else
            @$sendButton.addClass 'disabled'

    onToggle: ->
        w.promise (resolve)=>
            @$screen.off 'click'

            if @isOpen
                tracker.trackEvent c.tracking.category.feedback, 'toggle-closed'
                @$screen.css display:'none'
                @$page.removeClass 'blur'
                @$el.animate {left:-@_closeWidth}, duration:c.duration.fast, complete:=>
                    @$commentField.val ''
                    @$('input, textarea').blur()
                    resolve()
            else
                tracker.trackEvent c.tracking.category.feedback, 'toggle-open'
                @$page.addClass 'blur'
                @$screen.on 'click', => @onToggle()
                @$screen.css display:'block'

                @$el.animate {left:0}, duration:c.duration.fast, complete:=>
                    if @$nameField.val().length is 0
                        @$nameField.focus()
                    else if @$emailField.val().length is 0
                        @$emailField.focus()
                    else
                        @$commentField.focus()

                    resolve()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$page   = $('.page')
        @$screen = $('.view__screen')

        @$commentField = @$('textarea[name="comment"]')
        @$emailField   = @$('input[name="email"]')
        @$error        = @$('.error')
        @$nameField    = @$('input[name="name"]')
        @$sendButton   = @$('.button.send')

        @$el.css left:-@$el.outerWidth() * 1.25, opacity: 1.0;

        @_closeWidth = @$el.outerWidth() - @$('.tab').outerWidth()
        @$el.delay(c.duration.slow).animate {left:-@_closeWidth}, c.duration.normal
        @onTextChanged()

        @$error.css display:'none'
        @$sendButton.addClass 'disabled'

        super

    # Backbone.View Methods ########################################################################

    events: ->
        return _.extend super,
            'click .tab':     'onToggle'
            'click .button':  'onSendClicked'
            'input textarea': 'onTextChanged'
            'keyup textarea': 'onTextChanged'
