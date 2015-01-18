###
Crafting Guide - versioned_parser_base.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class VersionedParserBase

    constructor: (options={})->
        @_parsers       = @_createParsers options
        @_currentSchema = _.chain(@_parsers).keys().last().value()

    # Class Members ################################################################################

    @SCHEMA = /schema: *([0-9]+)/

    # Public Methods ###############################################################################

    parse: (text)->
        return unless text?

        schema = @_identifySchema text
        parser = @_parsers[schema]
        if not parser? then throw new Error "schema version #{schema} is not supported"

        parser.parse text

        return @_model

    unparse: (schema=null)->
        schema ?= @_currentSchema
        if not modVersion? then throw new Error 'modVersion is required'

        parser = @_parsers["#{schema}"]
        if not parser? then throw new Error "version #{schema} is not supported"

        return parser.unparse()

    # Overridable Methods ##########################################################################

    _createParsers: (options)->
        throw new Error 'subclasses must override this method'

    _identifySchema: (text)->
        match = VersionedParserBase.SCHEMA.exec text
        if not match? then throw new Error 'missing "schema" declaration'
        return match[1]
