###
Crafting Guide - markdown_image_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class MarkdownImageController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'markdown_image'
        super

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$image    = @$('img')
        @$fileName = @$('.fileName p')
        @$button   = @$('button')
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

        super
