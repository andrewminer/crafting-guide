#
# Crafting Guide - tutorial_parser.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

VersionedParserBase = require './versioned_parser_base'
TutorialParserV1    = require './tutorial_parser_v1'

########################################################################################################################

module.exports = class TutorialParser extends VersionedParserBase

    # VersionedParserBase Overrides ################################################################

    _createParsers: (options)->
        return result =
            '1': new TutorialParserV1 options
