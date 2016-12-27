#
# Crafting Guide - mod_parser.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

VersionedParserBase = require './versioned_parser_base'
ModParserV1         = require './mod_parser_v1'

########################################################################################################################

module.exports = class ModParser extends VersionedParserBase

    # VersionedParserBase Overrides ################################################################

    _createParsers: (options)->
        return result =
            '1': new ModParserV1 options
