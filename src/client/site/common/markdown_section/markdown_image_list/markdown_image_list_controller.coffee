#
# Crafting Guide - markdown_image_list_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController          = require '../../../base_controller'
MarkdownImageController = require './markdown_image/markdown_image_controller'
MarkdownImageList       = require '../../../../models/site/markdown_image_list'

########################################################################################################################

module.exports = class MarkdownImageListController extends BaseController

    constructor: (options={})->
        options.model ?= new MarkdownImageList {}, {client:options.client}
        options.templateName = 'common/markdown_section/markdown_image_list'
        super options

        @imageBase = ''
        @_valid = null

    # Public Methods ###############################################################################

    fetchImages: ->
        @model.fetchImages()

    getImageUrlForFile: (fileName)->
        @model.getFile(fileName).imageUrl

    reset: ->
        @model.reset()

    # Property Methods #############################################################################

    getImageBase: ->
        return @_imageBase

    setImageBase: (newImageBase)->
        oldImageBase = @_imageBase
        return unless oldImageBase isnt newImageBase

        @_imageBase = newImageBase
        @trigger c.event.change + ':imageBase', this, oldImageBase, newImageBase
        @trigger c.event.change, this

    getMarkdownText: ->
        return @model.markdownText

    setMarkdownText: (markdownText)->
        @model.markdownText = markdownText

    getValid: ->
        return @_valid

    Object.defineProperties @prototype,
        imageBase:    {get:@prototype.getImageBase,    set:@prototype.setImageBase}
        markdownText: {get:@prototype.getMarkdownText, set:@prototype.setMarkdownText}
        valid:        {get:@prototype.getValid}

    # BaseController Overrides #####################################################################

    onDidModelChange: ->
        super
        @_setValid @model.valid

    onDidRender: ->
        @$imageContainer = @$('.image_container')
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

    _setValid: (newValid)->
        oldValid = @_valid
        return if newValid is oldValid

        @_valid = newValid
        @trigger c.event.change + ':valid', this, oldValid, newValid
        @trigger c.event.change
