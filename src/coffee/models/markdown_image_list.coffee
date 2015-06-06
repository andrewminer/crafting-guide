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
        attributes.markdownText ?= null
        super attributes, options

        @_images = {}

        @on Event.change + ':markdownText', => @_analyzeMarkdownText()
        @_analyzeMarkdownText()

    # Property Methods #############################################################################

    getAll: ->
        fileNames = (fileName for fileName, image of @_images).sort()
        result = []
        for fileName in fileNames
            result.push @_images[fileName]

        return result

    Object.defineProperties @prototype,
        all: {get:@prototype.getAll}

    # Private Methods ##############################################################################

    _analyzeMarkdownText: ->
        regex = /\!\[([^\]]*)\]\(([^\)]*)\)/g
        newImages = {}
        changed = false

        if @markdownText?
            while true
                match = regex.exec @markdownText
                break unless match?

                fileName = match[2]
                image = @_images[fileName]
                if not image?
                    image = new MarkdownImage fileName:fileName
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
