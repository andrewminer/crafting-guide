###
Crafting Guide - markdown_image_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_              = require 'underscore'
BaseController = require './base_controller'
{Duration}     = require '../constants'
MarkdownImage  = require '../models/markdown_image'

########################################################################################################################

module.exports = class MarkdownImageController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'markdown_image'
        super

    # Event Methods ################################################################################

    onButtonClicked: ->
        @$input.click()

    onFileChanged: ->
        if @_reader? then @_reader.abort = true

        file = @$input.prop('files')[0]

        reader = @_reader = new FileReader
        reader.abort = false
        reader.onload = =>
            if reader.abort
                logger.info "aborted reading #{file.name}"
                return

            @_reader = null

            index       = reader.result.indexOf ','
            meta        = reader.result.substring 0, index
            encodedData = reader.result.substring index + 1

            match    = meta.match /data:(.*);(.*)/
            mimeType = match[1]
            encoding = match[2]

            @model.set
                encodedData: encodedData
                status:      MarkdownImage.Status.updateable

            logger.info "loaded #{encodedData.length} bytes from #{file.name} as #{mimeType}"

        logger.info "starting to read local file: #{file.name}"
        reader.readAsDataURL file

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$image          = @$('img')
        @$fileName       = @$('.fileName p')
        @$button         = @$('button')
        @$input          = @$('input')
        @$errorContainer = @$('.error')
        @$errorMessage   = @$('.error p')
        @$loaded         = @$('.loaded')
        @$loading        = @$('.loading')

        super

    refresh: ->
        if @model.mimeType? and @model.encodedData?
            @$image.attr 'src', "data:#{@model.mimeType};base64,#{@model.encodedData}"
        else
            @$image.attr 'src', '/images/unknown.png'

        @$fileName.html @model.fileName

        if @model.encodedData?
            @$button.html 'Update'
        else
            @$button.html 'Choose'

        if @model.status is MarkdownImage.Status.checking
            @$loaded.hide duration:Duration.normal
            @$loading.show duration:Duration.normal, queue:true
        else
            @$loading.hide duration:Duration.normal
            @$loaded.show duration:Duration.normal, queue:true

        if @model.status is MarkdownImage.Status.empty
            @$errorMessage.html 'please choose an image'
            @$errorContainer.show duration:Duration.normal
        else
            @$errorContainer.hide duration:Duration.normal

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click button': 'onButtonClicked'
            'change input': 'onFileChanged'
