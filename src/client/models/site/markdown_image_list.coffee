#
# Crafting Guide - markdown_image_list.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Observable}    = require("crafting-guide-common").util
MarkdownImage = require './markdown_image'

########################################################################################################################

module.exports = class MarkdownImageList extends Observable

    constructor: (options={})->
        super

        @_images = []
        @muted =>
            @client       = options.client
            @imageBase    = options.imageBase
            @markdownText = options.markdownText

        @_analyzeMarkdownText()

    # Public Methods ###############################################################################

    getFile: (fileName)->
        return @_images[fileName]

    fetchImages: ->
        for fileName, image of @_images
            if image.status is MarkdownImage::Status.unknown
                image.fetch()

    reset: ->
        for fileName, image of @_images
            @stopListening image

        @_images = {}
        @_analyzeMarkdownText()

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        all:
            get: ->
                fileNames = (fileName for fileName, image of @_images).sort()
                result = []
                for fileName in fileNames
                    result.push @_images[fileName]

                return result

        client:
            get: -> return @_client
            set: (client)->
                if not client? then throw new Error "client is required"
                @_client = client

        imageBase: ->
            get: -> return @_imageBase
            set: (imageBase)->
                @triggerPropertyChange "imageBase", @_imageBase, imageBase, ->
                    @_imageBase = imageBase
                    for fileName, image of @_images
                        image.path = @imageBase

        markdownText:
            get: -> return @_markdownText
            set: (markdownText)->
                @triggerPropertyChange "markdownText", @_markdownText, markdownText, ->
                    @_markdownText = markdownText
                    @_analyzeMarkdownText()

        valid:
            get: ->
                for fileName, image of @_images
                    return false unless image.valid
                return true

    # Private Methods ##############################################################################

    _analyzeMarkdownText: ->
        regex = /\!\[([^\]\n]*)\]\(([^\)\n]*)\)/g
        newImages = {}
        changed = false

        if @markdownText?
            while true
                match = regex.exec @markdownText
                break unless match?

                fileName = match[2]
                image = @_images[fileName]
                if not image?
                    image = new MarkdownImage {fileName:fileName, path:@imageBase}, {client:@client}
                    image.on Observable::CHANGE, this, "_onImageChanged"
                    @trigger Observable::ADD, image
                    changed = true

                newImages[fileName] = image

        for fileName, image of @_images
            if not newImages[fileName]?
                @trigger c.event.remove, this, image
                changed = true

        if changed
            @_images = newImages
            @trigger Observable::CHANGE

    _onImageChanged: ->
        @trigger Observable::CHANGE
