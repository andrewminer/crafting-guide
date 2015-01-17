###
Crafting Guide - mod_version_parser.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

Logger             = require '../logger'
ModVersionParserV1 = require './parser_versions/mod_version_parser_v1'
ModVersionParserV2 = require './parser_versions/mod_version_parser_v2'

########################################################################################################################

module.exports = class ModVersionParser

    @CURRENT_VERSION = '2'

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.showAllErrors ?= false

        @_model = options.model
        @_parsers =
            '1': new ModVersionParserV1 options
            '2': new ModVersionParserV2 options

    parse: (data)->
        if not data? then throw new Error 'mod description data is missing'

        if @_isJson data
            parser = @_parsers['1']
            data = JSON.parse data
        else
            parser = @_parsers['2']

        if not parser? then throw new Error "cannot parse version #{data.dataVersion} mod descriptions"
        parser.parse data

        return @_model

    unparse: (dataVersion=ModVersionParser.CURRENT_VERSION)->
        if not modVersion? then throw new Error 'modVersion is required'

        parser = @_parsers["#{dataVersion}"]
        if not parser? then throw new Error "version #{dataVersion} is not supported"

        return parser.unparse modVersion

    # Private Methods ##############################################################################

    _isJson: (data)->
        i = 0
        while i < data.length
            continue if data[i] is '\n'
            continue if data[i] is '\r'

            return true if data[i] is '{'
            return false
