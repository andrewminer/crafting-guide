#
# Crafting Guide - editable_file.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'

########################################################################################################################

module.exports = class EditableFile extends BaseModel

    @::MimeTypes = [
        { pattern:/\.cg$/i,   text:'text/plain' }
        { pattern:/\.png$/i,  text:'image/png' }
        { pattern:/\.gif$/i,  text:'image/gif' }
        { pattern:/\.jpg$/i,  text:'image/jpeg' }
        { pattern:/\.jpeg$/i, text:'image/jpeg' }
    ]

    @::Status = {
        'unknown':  'unknown'
        'checking': 'checking'
        'empty':    'empty'
        'clean':    'clean'
        'dirty':    'dirty'
    }

    constructor: (attributes={}, options={})->
        if not options.client? then throw new Error 'options.client is required'
        attributes.fileName    ?= ''
        attributes.path        ?= ''
        attributes.sha         ?= null
        super attributes, options

        @_client = options.client
        @_status = @Status.unknown
        @_encodedData = null

        @on c.event.change + ':fileName', => @_mimeType = null

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

        @trigger c.event.change + ':encodedData', this, oldEncodedData, newEncodedData
        @trigger c.event.change, this

    getFullPath: ->
        return "#{@path}/#{@fileName}"

    getMimeType: ->
        if not @_mimeType?
            for mimeType in @MimeTypes
                if mimeType.pattern.test @fileName
                    @_mimeType = mimeType.text
                    break

        return @_mimeType

    getStatus: ->
        return @_status

    isValid: ->
        return @_status in [ @Status.clean, @Status.dirty ]

    Object.defineProperties @prototype,
        encodedData: { get:@prototype.getEncodedData, set:@prototype.setEncodedData }
        fullPath:    { get:@prototype.getFullPath }
        imageUrl:    { get:@prototype.getImageUrl }
        mimeType:    { get:@prototype.getMimeType }
        status:      { get:@prototype.getStatus }
        valid:       { get:@prototype.isValid }

    # BaseModel Overrides ##########################################################################

    fetch: ->
        if not @_client? then throw new Error 'EditableFile must be given a client to fetch with'

        @_updateStatus @Status.checking
        @_client.fetchFile path:@fullPath
            .then (response)=>
                data = response.json.data

                if data.sha?
                    @encodedData = data.content
                    @sha         = data.sha
                    @_updateStatusForNewData()
                else
                    @_updateStatus @Status.empty

                return this

    save: (commitMessage)->
        return w(true) if @_status is @Status.clean
        return w(true) unless @encodedData?
        if not @valid then return w.reject new Error "cannot save with an invalid status: #{@_status}"

        commitMessage ?= "User-submitted update to #{@fileName} from #{global.hostName}"
        @_client.updateFile content:@encodedData, message:commitMessage, path:@fullPath, sha:@sha

    # Private Methods ##############################################################################

    _updateStatus: (newStatus)->
        oldStatus = @_status
        return if oldStatus is newStatus

        @_status = newStatus
        @trigger c.event.change, this, oldStatus, newStatus
        @trigger c.event.change, this

    _updateStatusForNewData: ->
        switch @_status
            when @Status.unknown
                @_updateStatus @Status.dirty
            when @Status.checking
                @_updateStatus @Status.clean
            when @Status.empty
                @_updateStatus @Status.dirty
            when @Status.clean
                @_updateStatus @Status.dirty
