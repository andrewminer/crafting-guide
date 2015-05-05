###
Crafting Guide - markdown_section_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController  = require './base_controller'
convertMarkdown = require 'marked'
_               = require 'underscore'
{Event}         = require '../constants'
{Url}           = require '../constants'

########################################################################################################################

module.exports = class MarkdownSectionController extends BaseController

    @State = State =
        viewing:    'viewing'
        editing:    'editing'
        previewing: 'previewing'
        error:      'error'

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.editable     ?= false
        options.imageBase    ?= ''
        options.model        ?= ''
        options.title        ?= 'Description'
        options.templateName  = 'markdown_section'
        super options

        @imageBase = options.imageBase
        @modPack   = options.modPack
        @title     = options.title

        @_editable = options.editable
        @_state = State.viewing

    # Event Methods ################################################################################

    onCancelClicked: (event)->
        event.preventDefault()
        @_state = State.viewing
        @_updateStateVisibility()

    onEditClicked: (event)->
        event.preventDefault()

        if global.router.user?
            @_state = State.editing
            @_updateStateVisibility()
        else
            global.router.login()

    onPreviewClicked: (event)->
        event.preventDefault()
        @_state = State.preview
        @_updateStateVisibility()

    onReturnClicked: (event)->
        event.preventDefault()
        @_state = State.editing
        @_updateStateVisibility()

    onSaveClicked: (event)->
        # TODO: implement logic to actually save changes
        @onCancelClicked event

    onTextChanged: (event)->
        event.preventDefault()
        @_updatePreview()
        @_updateSizer()

    # Property Methods #############################################################################

    isEditable: ->
        return @_editable

    setEditable: (editable)->
        return if @_editable is editable
        @_editable = editable
        @tryRefresh()

    Object.defineProperties @prototype,
        editable: {get:@prototype.isEditable, set:@prototype.setEditable}

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$buttonPanel   = @$('.buttons')
        @$cancelButton  = @$('button.cancel')
        @$editButton    = @$('button.edit')
        @$editorPanel   = @$('.editor')
        @$errorPanel    = @$('.error')
        @$errorText     = @$('.error p')
        @$markdownPanel = @$('.markdown')
        @$previewButton = @$('button.preview')
        @$returnButton  = @$('button.return')
        @$saveButton    = @$('button.save')
        @$sizer         = @$('.sizer')
        @$textarea      = @$('textarea')
        @$title         = @$('h2')

        super

    refresh: ->
        @$title.html @title

        @$textarea.val @model

        if @editable
            @show @$buttonPanel
        else
            @hide @$buttonPanel

        @_updateSizer()
        @_updatePreview()
        super

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
        text.replace /\!\[([^\]]*)\]\(([^\)]*)\)/g, (match, altText, fileName)=>
            return "![#{altText}](#{@imageBase}/#{fileName})"

    _convertWikiLinks: (text)->
        text.replace /\[\[([^\]]*)\]\]/g, (match, name)=>
            result = match
            item = @modPack.findItemByName name
            if item?
                display = @modPack.findItemDisplay item.slug
                result = "[#{name}](#{display.itemUrl})"

            return result

    _updateSizer: ->
        text = @$textarea.val()
        text = text.replace /\n/g, '<br>'
        @$sizer.html text

    _updatePreview: ->
        text = @$textarea.val()
        text = @_convertWikiLinks text
        text = @_convertImageLinks text

        @$markdownPanel.html convertMarkdown text

    _updateStateVisibility: ->
        toHide = []
        toShow = []
        errorText = ''

        if @_state is State.viewing
            toHide = [@$cancelButton, @$editorPanel, @$errorPanel, @$previewButton, @$returnButton, @$saveButton]
            toShow = [@$editButton, @$markdownPanel]
        else if @_state is State.editing
            toHide = [@$editButton, @$errorPanel, @$markdownPanel, @$previewButton, @$returnButton]
            toShow = [@$cancelButton, @$editorPanel, @$previewButton, @$saveButton]
        else if @_state is State.preview
            toHide    = [@$cancelButton, @$editButton, @$editorPanel, @$previewButton, @$saveButton]
            toShow    = [@$errorPanel, @$markdownPanel, @$returnButton]
            errorText = "remember: your changes aren't saved yet!"
        # else if @_state is State.error
            # TODO: Implement change to error state

        @hide $el for $el in toHide
        @once Event.animate.hide.finish, => @show $el for $el in toShow
        @$errorText.html errorText
