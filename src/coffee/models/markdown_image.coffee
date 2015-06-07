###
Crafting Guide - markdown_image.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
_         = require 'underscore'
{Event}   = require '../constants'

########################################################################################################################

module.exports = class MarkdownImage extends BaseModel

    @MimeTypes = MimeTypes = [
        {pattern:/\.png$/i,  text:'image/png'}
        {pattern:/\.gif$/i,  text:'image/gif'}
        {pattern:/\.jpg$/i,  text:'image/jpeg'}
        {pattern:/\.jpeg$/i, text:'image/jpeg'}
    ]

    @Status = Status = {
        'unknown':    'unknown'
        'checking':   'checking'
        'empty':      'empty'
        'creatable':  'creatable'
        'unchanged':  'unchanged'
        'updateable': 'updatable'
    }

    constructor: (attributes={}, options={})->
        attributes.encodedData ?= null
        attributes.fileName    ?= ''
        attributes.path        ?= ''
        attributes.sha         ?= null
        attributes.status      ?= Status.unknown
        super

        @client = options.client

        @on Event.change + ':fileName', => @_mimeType = null

    # Property Methods #############################################################################

    getFullPath: ->
        return "#{@path}/#{@fileName}"

    getMimeType: ->
        if not @_mimeType?
            for mimeType in MimeTypes
                if mimeType.pattern.test @fileName
                    @_mimeType = mimeType.text
                    break

        return @_mimeType

    Object.defineProperties @prototype,
        fullPath: {get:@prototype.getFullPath}
        mimeType: {get:@prototype.getMimeType}

    # BaseModel Overrides ##########################################################################

    fetch: ->
        if not @client? then throw new Error 'MarkdownImage must be given a client to fetch with'

        @status = Status.checking
        @client.fetchFile path:@fullPath
            .then (response)=>
                data = response.json.data

                if data.sha?
                    @set encodedData:data.content, sha:data.sha, status:Status.unchanged
                else
                    @status = Status.empty
