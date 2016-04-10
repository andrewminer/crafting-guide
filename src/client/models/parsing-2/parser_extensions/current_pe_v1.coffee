#
# Crafting Guide - current_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class CurrentParserExtensionV1 extends ParserExtension

    # Command Methods ##############################################################################

    _command_documentationUrl: (command)->
        current = @state.getCurrent()
        return if @duplicateField command, current, 'documentationUrl'
        return if @missingArgText command

        current.documentationUrl = command.argText

    _command_description: (command)->
        current = @state.getCurrent()
        return if @duplicateField command, current, 'description'
        return if @missingArgText command

        current.description = command.argText

    _command_name: (command)->
        current = @state.getCurrent()
        return if @duplicateField command, current, 'name'
        return if @missingArgText command

        current.name = command.argText
