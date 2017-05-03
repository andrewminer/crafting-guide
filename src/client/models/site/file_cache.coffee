#
# Crafting Guide - file_cache.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

w = require "when"

########################################################################################################################

module.exports = class FileCache extends Backbone.Events

    @::FILE_TOKEN = '#file='

    constructor: (url)->
        @_ajax    = $.ajax
        @_files   = {}
        @_loading = w.resolve(true)

        if url? then @loadArchive(url).catch(->)

    # Public Methods ###############################################################################

    getFile: (file)->
        return null unless @hasFile file
        return @_files[file]

    hasFile: (file)->
        return @_files[file]?

    loadArchive: (url)->
        if not _.isFunction(@_ajax) then throw new Error '$.ajax is required'

        newLoading = w.promise (resolve, reject)=>
            @_ajax
                url:      url
                dataType: 'text'
                success:  (text, status, xhr)=> resolve @_onLoadSuccess text, status, xhr
                error:    (xhr, status, error)=> resolve @_onLoadError error, status, xhr

        @_loading = w.join @_loading, newLoading

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        loading:
            get: -> return @_loading

    # Private Methods ##############################################################################

    _onLoadError: (error, status, xhr)->
        console.error "Failed to load archive: #{xhr.responseText}"
        return false

    _onLoadSuccess: (text, status, xhr)->
        return @_parseArchive text

    _parseArchive: (text)->
        file = null
        tokenIndex = nameStartIndex = nameEndIndex = fileStartIndex = fileEndIndex = 0
        fileCount = 0

        while true
            tokenIndex = text.indexOf @FILE_TOKEN, fileStartIndex
            if tokenIndex is -1
                if file?
                    @_files[file] = text.substring fileStartIndex, text.length
                    fileCount += 1
                break

            if file?
                fileEndIndex = tokenIndex
                @_files[file] = text.substring fileStartIndex, fileEndIndex
                fileCount += 1

            nameStartIndex = tokenIndex + @FILE_TOKEN.length
            nameEndIndex = text.indexOf '\n', nameStartIndex
            if nameEndIndex is -1
                file = text.substring nameStartIndex, text.length
                @_files[file] = ''
                break

            file = text.substring nameStartIndex, nameEndIndex
            fileStartIndex = nameEndIndex + '\n'.length

        return fileCount > 0
