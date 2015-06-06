###
Crafting Guide - markdown_image.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Event}   = require '../constants'

########################################################################################################################

module.exports = class MarkdownImage extends BaseModel

    @MIMETYPES = [
        {patern:/\.png$/i, text:'image/png'}
        {patern:/\.gif$/i, text:'image/gif'}
        {patern:/\.jpg$/i, text:'image/jpeg'}
        {patern:/\.jpeg$/i, text:'image/jpeg'}
    ]

    constructor: (attributes={}, options={})->
        attributes.encodedData ?= null
        attributes.fileName    ?= ''
        attributes.path        ?= ''
        attributes.sha         ?= null
        super

        @on Event.change + ':fileName', => @_mimeType = null

    # Property Methods #############################################################################

    getFullPath: ->
        return "#{@path}/#{@fileName}"

    getMimeType: ->
        if not @_mimeType?
            for mimeType in MarkdownImage.MIMETYPES
                if mimeType.pattern.test @fileName
                    @_mimeType = mimeType.text
                    break

        return @_mimeType

    Object.defineProperties @prototype,
        fullPath: {get:@prototype.getFullPath}
