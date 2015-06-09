###
Crafting Guide - markdown_section_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_                           = require 'underscore'
BaseController              = require './base_controller'
convertMarkdown             = require 'marked'
{Event}                     = require '../constants'
MarkdownImageListController = require './markdown_image_list_controller'
{Url}                       = require '../constants'
w                           = require 'when'

########################################################################################################################

module.exports = class MarkdownSectionController extends BaseController

    @State = State =
        appologizing: 'applogizing'
        confirming:   'confirming'
        creating:     'creating'
        editing:      'editing'
        previewing:   'previewing'
        viewing:      'viewing'
        waiting:      'waiting'

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.model        ?= null
        options.templateName  = 'markdown_section'
        @_state = State.waiting
        super options

        @on Event.animate.hide.finish, => @_updateStateVisibility()
        @on Event.animate.show.finish, => @_updateStateVisibility()

        @client               = options.client
        @confirmactionMessage = options.confirmationMessage
        @confirmDuration      = options.confirmationDuration ?= 5000
        @imageBase            = options.imageBase            ?= ''
        @modPack              = options.modPack
        @title                = options.title                ?= 'Description'

        # @_beginEditing must be a function returning a promise which resolves when all actions necessary prior to an
        # editing session have been completed (e.g., loading the latest content from a remote server). The promise must
        # reject if an error occured which should prevent editing.
        @_beginEditing = options.beginEditing

        # @_endEditing must be a function returning a promise which resolves when the model of this controller has been
        # saved however is appropriate. The promise must reject if saving failed for some reason.
        @_endEditing = options.endEditing

    # Public Methods ###############################################################################

    resetToDefaultState: ->
        if @model?
            @state = State.viewing
        else
            if @editable?
                @state = State.creating
            else
                @state = State.waiting

    # Event Methods ################################################################################

    onCancelClicked: (event)->
        event.preventDefault()
        @model = @_originalModel
        @resetToDefaultState()

        @_imageListController.reset()
        @_updatePreview()

    onEditClicked: (event)->
        event.preventDefault()
        return unless @editable

        @_originalModel = @model
        @state = State.waiting
        @_beginEditing()
            .then =>
                @state = State.editing
            .catch (e)=>
                logger.warning "cannot begin editing: #{e.stack}"
                @state = State.appologizing
                w(true).delay(@confirmDuration).then => @resetToDefaultState()

    onPreviewClicked: (event)->
        event.preventDefault()
        @_updatePreview()
        @state = State.previewing

    onReturnClicked: (event)->
        event.preventDefault()
        @state = State.editing

    onSaveClicked: (event)->
        event.preventDefault()

        @state = State.waiting
        @_endEditing()
            .then =>
                @state = State.confirming
            .catch (e)=>
                message = if e.stack? then e.stack else e
                logger.error "failed to end editing: #{message}"
                @state = State.appologizing
            .delay @confirmDuration
            .then =>
                @state = State.viewing

    onTextChanged: (event)->
        event.preventDefault()
        @model = @$textarea.val()

    # Property Methods #############################################################################

    isEditable: ->
        return _.isFunction(@_beginEditing) and _.isFunction(@_endEditing)

    getImageBase: ->
        return @_imageBase

    setImageBase: (newImageBase)->
        oldImageBase = @_imageBase
        return unless newImageBase isnt oldImageBase

        @_imageBase = newImageBase
        @trigger Event.change + ':imageBase', this, oldImageBase, newImageBase
        @trigger Event.change, this

    getImageFiles: ->
        return @_imageListController.model.all

    getState: ->
        return @_state

    setState: (newState)->
        oldState = @_state
        return if oldState is newState
        @_state = newState

        logger.verbose => "MarkdownSectionController.#{@cid} changed state from #{oldState} to #{newState}"
        @trigger Event.change + ':state', this, oldState, newState
        @_updateStateVisibility()

    Object.defineProperties @prototype,
        editable:   { get:@prototype.isEditable }
        imageBase:  { get:@prototype.getImageBase, set:@prototype.setImageBase }
        imageFiles: { get:@prototype.getImageFiles }
        state:      { get:@prototype.getState,     set:@prototype.setState }

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_imageListController = @addChild MarkdownImageListController, '.image_list',
            client: @client
            imageBase: @imageBase
        @on Event.change + ':imageBase', => @_imageListController.model.imageBase = @imageBase
        @listenTo @_imageListController, Event.change + ':valid', => @tryRefresh()

        @$errorText     = @$('.error p')
        @$markdownPanel = @$('.markdown')
        @$previewButton = @$('button.preview')
        @$saveButton    = @$('button.save')
        @$sizer         = @$('.sizer')
        @$textarea      = @$('textarea')
        @$title         = @$('h2')

        @resetToDefaultState()

        super

    refresh: ->
        @$title.html @title
        @_imageListController.markdownText = @model

        @_updateButtonStates()
        @_updateSizer()
        @_updatePreview()
        super

    onWillChangeModel: (oldModel, newModel)->
        @$textarea.val newModel
        super oldModel, newModel

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .markdown a':    'routeLinkClick'
            'click button.cancel':  'onCancelClicked'
            'click button.edit':    'onEditClicked'
            'click button.preview': 'onPreviewClicked'
            'click button.return':  'onReturnClicked'
            'click button.save':    'onSaveClicked'
            'input textarea':       'onTextChanged'

    # Private Methods ##############################################################################

    _convertImageLinks: (text)->
        text.replace /\<img src="([^"]*)"/g, (match, fileName)=>
            return "<img src=\"#{@_imageListController.getImageUrlForFile(fileName)}\""

    _convertWikiLinks: (text)->
        text.replace /\[\[([^\]]*)\]\]/g, (match, name)=>
            result = match
            item = @modPack.findItemByName name
            if item?
                display = @modPack.findItemDisplay item.slug
                result = "[#{name}](#{display.itemUrl})"

            return result

    _updateButtonStates: ->
        for $button in [ @$previewButton, @$saveButton ]
            if @_imageListController.valid
                $button.prop 'disabled', false
            else
                $button.prop 'disabled', true

    _updateSizer: ->
        text = @model
        if @model?
            text = text.replace /\n/g, '<br>'

        @$sizer.html text

    _updatePreview: ->
        text = @model
        if @model?
            text = @_convertWikiLinks text
            text = convertMarkdown text
            text = @_convertImageLinks text

        @$markdownPanel.html text

    _updateStateVisibility: ->
        return if @_lastUpdatedState is @state
        @_lastUpdatedState = @state

        elements =
            appologizingPanel: @$('.appologizing')
            buttonPanel:       @$('.buttons')
            cancelButton:      @$('button.cancel')
            confirmingPanel:   @$('.confirming')
            creatingPanel:     @$('.creating')
            editButton:        @$('button.edit')
            editorPanel:       @$('.editor')
            errorPanel:        @$('.error')
            imageList:         @$('.image_list')
            markdownPanel:     @$markdownPanel
            previewButton:     @$previewButton
            returnButton:      @$('button.return')
            saveButton:        @$saveButton
            waitingPanel:      @$('.waiting')

        visible = {}
        errorText = ''

        if @state is State.appologizing
            visible = appologizingPanel:true
        else if @state is State.confirming
            visible = confirmingPanel:true
        else if @state is State.creating
            visible = buttonPanel:true, creatingPanel:true, editButton:true
        else if @state is State.editing
            visible = buttonPanel:true, cancelButton:true, editorPanel:true, previewButton:true, imageList:true
        else if @state is State.previewing
            visible = buttonPanel:true, errorPanel:true, markdownPanel:true, returnButton:true, saveButton:true
            errorText = "remember: your changes aren't saved yet!"
        else if @state is State.viewing
            visible = markdownPanel:true
            if @editable then _.extend visible, {buttonPanel:true, editButton:true}
        else # assume any unknown state is the same as "waiting"
            visible = waitingPanel:true

        toHide = ($el for name, $el of elements when not visible[name])
        toShow = ($el for name, $el of elements when visible[name])

        if toHide.length > 0
            @hide $el for $el in toHide
            if toShow.length > 0
                @once Event.animate.hide.finish, =>
                    @show $el for $el in toShow
        else if toShow.length > 0
            @show $el for $el in toShow

        if @state is State.editing
            @once Event.animate.show.finish, =>
                @$textarea.focus()

        @$errorText.html errorText
