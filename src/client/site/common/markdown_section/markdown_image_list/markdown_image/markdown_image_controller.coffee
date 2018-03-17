###
Crafting Guide - markdown_image_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require '../../../../base_controller'
MarkdownImage  = require '../../../../../models/site/markdown_image'

########################################################################################################################

module.exports = class MarkdownImageController extends BaseController

    @::MAX_FILE_SIZE = 750 * 1024
    @::MAX_HEIGHT    = 600
    @::MAX_WIDTH     = 740

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'common/markdown_section/markdown_image_list/markdown_image'
        super

        @_errorMessage = null

    # Event Methods ################################################################################

    onButtonClicked: ->
        @$input.click()

    onFileChanged: ->
        if @_reader? then @_reader.abort = true

        file = @$input.prop('files')[0]
        return unless file?

        if file.size > @MAX_FILE_SIZE
            logger.warning "The choosen file, #{file.name}, is too large: #{file.size}"
            @errorMessage = "Choose a file less than #{@MAX_FILE_SIZE / 1024}kB"
            @_clearFile()
            return

        reader = @_reader = new FileReader
        reader.abort = false

        reader.onload = =>
            if reader.abort
                logger.info "aborted reading #{file.name}"
                return

            @_reader = null

            $image = $("<img src=\"#{reader.result}\">")
            $image.load =>
                if $image[0].naturalHeight > @MAX_HEIGHT
                    logger.warning "The choosen file, #{file.name}, is too tall: #{$image[0].naturalHeight}"
                    @errorMessage = "Choose an image less than #{@MAX_HEIGHT}px tall"
                    @_clearFile()
                    return

                if $image[0].naturalWidth > @MAX_WIDTH
                    logger.warning "The choosen file, #{file.name}, is too wide: #{$image[0].naturalWidth}"
                    @errorMessage = "Choose an image less than #{@MAX_WIDTH}px wide"
                    @_clearFile()
                    return

                index       = reader.result.indexOf ','
                meta        = reader.result.substring 0, index
                encodedData = reader.result.substring index + 1

                match    = meta.match /data:(.*);(.*)/
                mimeType = match[1]
                encoding = match[2]

                @model.encodedData = encodedData
                logger.info "loaded #{encodedData.length} bytes from #{file.name} as #{mimeType}"
                @errorMessage = null
                @_clearFile()

        logger.info "starting to read local file: #{file.name}"
        reader.readAsDataURL file

    # Property Methods #############################################################################

    getErrorMessage: ->
        return @_errorMessage

    setErrorMessage: (newErrorMessage)->
        oldErrorMessage = @_errorMessage
        return if newErrorMessage is oldErrorMessage

        @_errorMessage = newErrorMessage
        @trigger Event.change + ':errorMessage', this, oldErrorMessage, newErrorMessage
        @trigger Event.change, this

        @tryRefresh()

    Object.defineProperties @prototype,
        errorMessage: { get:@prototype.getErrorMessage, set:@prototype.setErrorMessage }

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$image          = @$('img')
        @$fileName       = @$('.fileName p')
        @$buttonLabel    = @$('.button p')
        @$form           = @$('form')
        @$input          = @$('input')
        @$errorContainer = @$('.error')
        @$errorMessage   = @$('.error p')
        @$loaded         = @$('.loaded')
        @$loading        = @$('.loading')

        super

    onWillChangeModel: (oldModel, newModel)->
        @errorMessage = null
        super oldModel, newModel

    refresh: ->
        if @model.mimeType? and @model.encodedData?
            @$image.attr 'src', "data:#{@model.mimeType};base64,#{@model.encodedData}"
        else
            @$image.attr 'src', '/images/unknown.png'

        @$fileName.html @model.fileName

        if @model.encodedData?
            @$buttonLabel.html 'Update'
        else
            @$buttonLabel.html 'Choose'

        if @model.status is MarkdownImage::Status.checking
            @hide @$loaded
            @show @$loading
        else
            @hide @$loading
            @show @$loaded

        if @errorMessage?
            @$errorMessage.html @errorMessage
            @show @$errorContainer
        else if @model.status is MarkdownImage::Status.empty
            @$errorMessage.html 'please choose an image'
            @show @$errorContainer
        else
            @hide @$errorContainer

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .button': 'onButtonClicked'
            'change input': 'onFileChanged'

    # Private Methods ##############################################################################

    _clearFile: ->
        @$form[0].reset()
