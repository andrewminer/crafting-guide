###
Crafting Guide - markdown_image_list.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel     = require './base_model'
{Event}       = require '../constants'
MarkdownImage = require './markdown_image'

########################################################################################################################

module.exports = class MarkdownImageList extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.imageBase    ?= ''
        attributes.markdownText ?= null
        super attributes, options

        @client = options.client
        @_images = {}

        @on Event.change + ':imageBase', =>
            for fileName, image of @_images
                image.path = @imageBase

        @on Event.change + ':markdownText', => @_analyzeMarkdownText()
        @_analyzeMarkdownText()

    # Public Methods ###############################################################################

    getImageUrlForFile: (fileName)->
        result = @_images[fileName]?.imageUrl
        result ?= "#{@imageBase}/#{fileName}"
        return result

    loadImages: ->
        for fileName, image of @_images
            if image.status is MarkdownImage.Status.unknown
                image.fetch()

    reset: ->
        for fileName, image of @_images
            @stopListening image

        @_images = {}
        @_analyzeMarkdownText()

    # Property Methods #############################################################################

    getAll: ->
        fileNames = (fileName for fileName, image of @_images).sort()
        result = []
        for fileName in fileNames
            result.push @_images[fileName]

        return result

    isValid: ->
        for fileName, image of @_images
            return false unless image.valid
        return true

    Object.defineProperties @prototype,
        all: {get:@prototype.getAll}
        valid: {get:@prototype.isValid}

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
                    @listenTo image, Event.change, => @trigger Event.change, this
                    @trigger Event.add, this, image
                    changed = true

                newImages[fileName] = image

        for fileName, image of @_images
            if not newImages[fileName]?
                @trigger Event.remove, this, image
                changed = true

        if changed
            @_images = newImages
            @trigger Event.change, this
