###
Crafting Guide - editable_file.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Event}   = require '../constants'
w         = require 'when'

########################################################################################################################

module.exports = class EditableFile extends BaseModel

    @MimeTypes = MimeTypes = [
        { pattern:/\.cg$/i,   text:'text/plain' }
        { pattern:/\.png$/i,  text:'image/png' }
        { pattern:/\.gif$/i,  text:'image/gif' }
        { pattern:/\.jpg$/i,  text:'image/jpeg' }
        { pattern:/\.jpeg$/i, text:'image/jpeg' }
    ]

    @Status = Status = {
        'unknown':  'unknown'
        'checking': 'checking'
        'empty':    'empty'
        'clean':    'clean'
        'dirty':    'dirty'
    }

    constructor: (attributes={}, options={})->
        attributes.fileName    ?= ''
        attributes.path        ?= ''
        attributes.sha         ?= null
        attributes.status      ?= Status.unknown
        super

        @client = options.client
        @_encodedData = null

        @on Event.change + ':fileName', => @_mimeType = null

    # Public Methods ###############################################################################

    getDecodedData: (targetEncoding='utf8')->
        return new Buffer(@encodedData, 'base64').toString(targetEncoding)

    setDecodedData: (text, sourceEncoding='utf8')->
        @encodedData = new Buffer(text, sourceEncoding).toString('base64')

    # Property Methods #############################################################################

    getDataAsText: ->
        if not @_dataAsText
            @_dataAsText = new Buffer(@encodedData, 'base64').toString('utf8')
        return @_dataAsText

    getEncodedData: ->
        return @_encodedData

    setEncodedData: (newEncodedData)->
        oldEncodedData = @_encodedData
        return if newEncodedData is oldEncodedData

        @_encodedData = newEncodedData
        @_updateStatusForNewData()

        @trigger Event.change + ':encodedData', this, oldEncodedData, newEncodedData
        @trigger Event.change, this

    getFullPath: ->
        return "#{@path}/#{@fileName}"

    getMimeType: ->
        if not @_mimeType?
            for mimeType in MimeTypes
                if mimeType.pattern.test @fileName
                    @_mimeType = mimeType.text
                    break

        return @_mimeType

    isValid: ->
        return @status in [ Status.clean, Status.dirty ]

    Object.defineProperties @prototype,
        encodedData: { get:@prototype.getEncodedData, set:@prototype.setEncodedData }
        fullPath:    { get:@prototype.getFullPath }
        imageUrl:    { get:@prototype.getImageUrl }
        mimeType:    { get:@prototype.getMimeType }
        valid:       { get:@prototype.isValid }

    # BaseModel Overrides ##########################################################################

    fetch: ->
        if not @client? then throw new Error 'EditableFile must be given a client to fetch with'

        @status = Status.checking
        @client.fetchFile path:@fullPath
            .then (response)=>
                data = response.json.data

                if data.sha?
                    @encodedData = data.content
                    @sha         = data.sha
                else
                    @status = Status.empty

                return this

    save: (commitMessage)->
        return w(true) if @status is Status.unchanged
        return w(true) unless @encodedData?
        if not @valid then return w.reject new Error "cannot save with an invalid status: #{@status}"

        commitMessage ?= "User-submitted update to #{@fileName} from #{global.hostName}"
        @client.updateFile content:@encodedData, message:commitMessage, path:@fullPath, sha:@sha

    # Private Methods ##############################################################################

    _updateStatusForNewData: ->
        switch @status
            when Status.unknown  then @status = Status.dirty
            when Status.checking then @status = Status.clean
            when Status.empty    then @status = Status.dirty
            when Status.clean    then @status = Status.dirty
