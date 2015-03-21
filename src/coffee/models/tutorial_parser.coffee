###
Crafting Guide - tutorial_parser.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

VersionedParserBase = require './versioned_parser_base'
TutorialParserV1    = require './parser_versions/tutorial_parser_v1'

########################################################################################################################

module.exports = class TutorialParser extends VersionedParserBase

    # VersionedParserBase Overrides ################################################################

    _createParsers: (options)->
        return result =
            '1': new TutorialParserV1 options
