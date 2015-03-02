###
Crafting Guide - feedback_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Duration}     = require '../constants'
EmailClient    = require '../models/email_client'
{Key}          = require '../constants'

########################################################################################################################

module.exports = class FeedbackController extends BaseController

    constructor: (options={})->
        options.model ?= new EmailClient
        options.templateName = 'feedback'
        super options

        Object.defineProperty this, 'isOpen', get:-> @$el.offset().left is 0

    # Public Methods ###############################################################################

    enterFeedback: (message)->
        promise = w(true)
        if not @isOpen then promise = @onToggle()
        promise.then => @$commentField.val message

    # Event Methods ################################################################################

    onSendClicked: ->
        return unless @$commentField.val().length > 0
        @$sendButton.attr 'disabled', 'disabled'

        message =
            subject:'Crafting Guide Feedback'
            body:
                """
                url: #{window.location.href}
                name: #{@$nameField.val()}
                email: #{@$emailField.val()}
                comment:

                #{@$commentField.val()}
                """

        @model.send(message)
            .then =>
                @onToggle()
                @$error.slideUp duration:Duration.normal
            .catch (error)=>
                @$error.slideDown duration:Duration.normal
            .finally =>
                @$sendButton.removeAttr 'disabled'

    onTextChanged: (event)->
        if @$commentField.val().length > 0
            @$sendButton.removeAttr 'disabled'
        else
            @$sendButton.attr 'disabled', 'disabled'

    onToggle: ->
        w.promise (resolve)=>
            @$screen.off 'click'

            if @isOpen
                @$screen.css display:'none'
                @$el.animate {left:-@$el.outerWidth()}, duration:Duration.fast, complete:=>
                    @$commentField.val ''
                    @$('input, textarea').blur()
                    resolve()
            else
                @$screen.on 'click', => @onToggle()
                @$screen.css display:'block'

                @$el.animate {left:0}, duration:Duration.fast, complete:=>
                    if @$nameField.val().length is 0
                        @$nameField.focus()
                    else if @$emailField.val().length is 0
                        @$emailField.focus()
                    else
                        @$commentField.focus()

                    resolve()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$screen = $('.view__screen')

        @$commentField = @$('textarea[name="comment"]')
        @$emailField   = @$('input[name="email"]')
        @$error        = @$('.error')
        @$nameField    = @$('input[name="name"]')
        @$sendButton   = @$('button[name="send"]')

        windowHeight = window.innerHeight
        @$el.delay(Duration.slow).animate {left:-@$el.outerWidth()}, Duration.normal
        @onTextChanged()

        super

    # Backbone.View Methods ########################################################################

    events: ->
        return _.extend super,
            'click .label':   'onToggle'
            'click button':   'onSendClicked'
            'input textarea': 'onTextChanged'
            'keyup textarea': 'onTextChanged'
