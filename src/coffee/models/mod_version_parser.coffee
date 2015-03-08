###
Crafting Guide - mod_version_parser.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

VersionedParserBase = require './versioned_parser_base'
ModVersionParserV1  = require './parser_versions/mod_version_parser_v1'

########################################################################################################################

module.exports = class ModVersionParser extends VersionedParserBase

    # VersionedParserBase Overrides ################################################################

    _createParsers: (options)->
        return result =
            '1': new ModVersionParserV1 options
