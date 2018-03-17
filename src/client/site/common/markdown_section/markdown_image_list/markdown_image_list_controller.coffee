#
# Crafting Guide - markdown_image_list_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_                       = require "../../../../../underscore"
c                       = require "../../../../../common/constants"
BaseController          = require "../../../base_controller"
MarkdownImageController = require "./markdown_image/markdown_image_controller"
MarkdownImageList       = require "../../../../models/site/markdown_image_list"
{Observable}            = require("crafting-guide-common").util

########################################################################################################################

module.exports = class MarkdownImageListController extends BaseController
    _.extend this, Observable

    constructor: (options={})->
        options.model ?= new MarkdownImageList client:options.client
        options.templateName = "common/markdown_section/markdown_image_list"
        super options

        @imageBase = ""
        @_valid = null

    # Public Methods ###############################################################################

    fetchImages: ->
        @model.fetchImages()

    getImageUrlForFile: (fileName)->
        @model.getFile(fileName).imageUrl

    reset: ->
        @model.reset()

    # Property Methods #############################################################################
    
    Object.defineProperties @prototype,

        imageBase:
            get: -> return @_imageBase
            set: (imageBase)->
                @_imageBase = imageBase
                @trigger c.event.change

        markdownText:
            get: -> return @model.markdownText
            set: (markdownText)->
                @model.markdownText = markdownText
                @trigger c.event.change

        valid:
            get: -> return @_valid
            set: -> throw new Error "valid cannot be assigned"

    # BaseController Overrides #####################################################################

    onDidModelChange: ->
        super
        @_setValid @model.valid

    onDidRender: ->
        @$imageContainer = @$(".image_container")
        super

    refresh: ->
        @_controllers ?= []
        index = 0

        for image in @model.all
            controller = @_controllers[index]
            if not controller?
                controller = new MarkdownImageController model:image
                @_controllers.push controller
                @$imageContainer.append controller.$el
                controller.render()
            else
                controller.model = image

            index += 1

        while @_controllers.length > index
            @_controllers.pop().remove()

    # Private Methods ##############################################################################

    _setValid: (valid)->
        @_valid = valid
        @trigger c.event.change
