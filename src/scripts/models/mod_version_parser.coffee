###
Crafting Guide - mod_version_parser.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

Logger = require '../logger'
V1     = require './mod_version_parsers/v1'

########################################################################################################################

module.exports = class ModVersionParser

    @CURRENT_VERSION = '1'

    constructor: ->
        @_parsers =
            '1': new V1

    parse: (data)->
        if not data? then throw new Error 'mod description data is missing'
        if not data.dataVersion? then throw new Error 'dataVersion is required'

        parser = @_parsers["#{data.dataVersion}"]
        if not parser? then throw new Error "cannot parse version #{data.dataVersion} mod descriptions"

        oldLevel = logger.level
        logger.level = Logger.WARNING
        result = parser.parse data
        logger.level = oldLevel

        return result

    unparse: (modVersion, dataVersion=ModVersionParser.CURRENT_VERSION)->
        if not modVersion? then throw new Error 'modVersion is required'

        parser = @_parsers["#{dataVersion}"]
        if not parser? then throw new Error "version #{dataVersion} is not supported"

        return parser.unparse modVersion
