#
# Crafting Guide - mod_version_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class ModVersionParserExtensionV1 extends ParserExtension

    constructor: (data)->
        super data, 'modVersion',
            group:   @_command_group
            version: @_command_version

    # Command Methods ##############################################################################

    _command_group: (command)->
        return if @missingArgText command
        return if @missingCurrent command, 'modVersion'

        group = @data.create command, 'itemGroup', command.argText
        group.modVersion = @data.getCurrent 'modVersion'

    _command_version: (command)->
        return if @missingArgText command
        return if @missingCurrent command, 'mod'

        modVersion = @data.create command, 'modVersion', command.argText
        modVersion.mod = @data.getCurrent 'mod'
