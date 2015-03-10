###
Crafting Guide - item_parser.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

VersionedParserBase = require './versioned_parser_base'
ItemParserV1  = require './parser_versions/item_parser_v1'

########################################################################################################################

module.exports = class ItemParser extends VersionedParserBase

    # VersionedParserBase Overrides ################################################################

    _createParsers: (options)->
        return result =
            '1': new ItemParserV1 options
