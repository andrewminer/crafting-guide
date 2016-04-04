#
# Crafting Guide - markdown_section_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController              = require '../../base_controller'
convertMarkdown             = require 'marked'
MarkdownImageListController = require './markdown_image_list/markdown_image_list_controller'

########################################################################################################################

module.exports = class MarkdownSectionController extends BaseController

    @::State =
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
        options.templateName  = 'common/markdown_section'
        @_state = @State.waiting
        super options

        @_client              = options.client
        @_confirmationMessage = options.confirmationMessage
        @_confirmDuration     = options.confirmationDuration or 5000
        @_enterFeedback       = options.enterFeedback        or -> # do nothing
        @_imageBase           = options.imageBase            or ''
        @_modPack             = options.modPack
        @_title               = options.title                or 'Description'

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
            @state = @State.viewing
        else
            if @editable?
                @state = @State.creating
            else
                @state = @State.waiting

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
        @state = @State.waiting
        @_beginEditing()
            .then =>
                @state = @State.editing
            .catch (e)=>
                logger.warning "cannot begin editing: #{e.stack}"
                @state = @State.appologizing
                w(true).delay(@_confirmDuration).then => @resetToDefaultState()

    onQuestionClicked: (event)->
        event.preventDefault()
        @_enterFeedback ''

    onPreviewClicked: (event)->
        event.preventDefault()
        @_updatePreview()
        @state = @State.previewing

    onReturnClicked: (event)->
        event.preventDefault()
        @state = @State.editing

    onSaveClicked: (event)->
        event.preventDefault()

        @state = @State.waiting
        @_endEditing()
            .then =>
                @state = @State.confirming
            .catch (e)=>
                message = if e.stack? then e.stack else e
                logger.error "failed to end editing: #{message}"
                @state = @State.appologizing
            .delay @_confirmDuration
            .then =>
                @state = @State.viewing

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
        @trigger c.event.change + ':imageBase', this, oldImageBase, newImageBase
        @trigger c.event.change, this

    getImageFiles: ->
        return @_imageListController.model.all

    getState: ->
        return @_state

    setState: (newState)->
        oldState = @_state
        return if oldState is newState
        @_state = newState

        logger.verbose => "MarkdownSectionController.#{@cid} changed state from #{oldState} to #{newState}"
        @trigger c.event.change + ':state', this, oldState, newState
        @tryRefresh()

    Object.defineProperties @prototype,
        editable:   { get:@prototype.isEditable }
        imageBase:  { get:@prototype.getImageBase, set:@prototype.setImageBase }
        imageFiles: { get:@prototype.getImageFiles }
        state:      { get:@prototype.getState,     set:@prototype.setState }

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_imageListController = @addChild MarkdownImageListController, '.view__markdown_image_list',
            client: @_client
            imageBase: @_imageBase
        @on c.event.change + ':imageBase', => @_imageListController.model.imageBase = @_imageBase
        @listenTo @_imageListController, c.event.change + ':valid', => @tryRefresh()

        @$errorPanel    = @$('.error')
        @$errorText     = @$('.error p')
        @$markdownPanel = @$('.markdown')
        @$previewButton = @$('.button.preview')
        @$questionPanel = @$('.question')
        @$saveButton    = @$('.button.save')
        @$sizer         = @$('.sizer')
        @$textarea      = @$('textarea')
        @$title         = @$('h2')

        @resetToDefaultState()

        super

    refresh: ->
        @$title.html @_title
        @_imageListController.markdownText = @model
        @_imageListController.fetchImages() if @state is @State.editing

        @_updateButtonStates()
        @_updateSizer()
        @_updatePreview()
        @_updateStateVisibility()

        super

    onWillChangeModel: (oldModel, newModel)->
        if @rendered then @$textarea.val newModel
        super oldModel, newModel

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .markdown a':     'routeLinkClick'
            'click .button.cancel':  'onCancelClicked'
            'click .button.edit':    'onEditClicked'
            'click .button.preview': 'onPreviewClicked'
            'click .button.return':  'onReturnClicked'
            'click .button.save':    'onSaveClicked'
            'click .question a':     'onQuestionClicked'
            'input textarea':        'onTextChanged'

    # Private Methods ##############################################################################

    _convertImageLinks: (text)->
        text.replace /\<img src="([^"]*)"/g, (match, fileName)=>
            return "<img src=\"#{@_imageListController.getImageUrlForFile(fileName)}\""

    _convertWikiLinks: (text)->
        text.replace /\[\[([^\]]*)\]\]/g, (match, name)=>
            result = match
            item = @_modPack.findItemByName name
            if item?
                display = @_modPack.findItemDisplay item.slug
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

        logger.verbose => "Updating markdown section visibility for state: #{@state}"

        elements =
            appologizingPanel: @$('.appologizing')
            cancelButton:      @$('.button.cancel')
            confirmingPanel:   @$('.confirming')
            creatingPanel:     @$('.creating')
            editButton:        @$('.button.edit')
            editorPanel:       @$('.editor')
            footerPanel:       @$('.footer')
            imageList:         @$('.view__markdown_image_list')
            markdownPanel:     @$markdownPanel
            previewButton:     @$previewButton
            returnButton:      @$('.button.return')
            saveButton:        @$saveButton
            waitingPanel:      @$('.waiting')

        visible = {}
        errorText = ''

        if @state is @State.appologizing
            visible = appologizingPanel:true
        else if @state is @State.confirming
            visible = confirmingPanel:true
        else if @state is @State.creating
            visible = footerPanel:true, creatingPanel:true, editButton:true
        else if @state is @State.editing
            visible = footerPanel:true, editorPanel:true, cancelButton:true, previewButton:true, imageList:true
        else if @state is @State.previewing
            visible = footerPanel:true, markdownPanel:true, returnButton:true, saveButton:true
            errorText = "remember: your changes aren't saved yet!"
        else if @state is @State.viewing
            visible = markdownPanel:true
            if @editable then _.extend visible, {footerPanel:true, editButton:true}
        else # assume any unknown state is the same as "waiting"
            visible = waitingPanel:true

        for name, $el of elements when not visible[name]
            @hide $el
        for name, $el of elements when visible[name]
            @show $el

        if @state is @State.editing then @$textarea.focus()

        @$errorText.html errorText
        if errorText.length > 0
            @show @$errorPanel
            @hide @$questionPanel
        else
            @hide @$errorPanel
            @show @$questionPanel
