#
# Crafting Guide - current_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class CurrentParserExtensionV1 extends ParserExtension

    constructor: (data)->
        super data, null,
            documentationUrl: @_command_documentationUrl
            description:      @_command_description
            name:             @_command_name

    # Command Methods ##############################################################################

    _command_documentationUrl: (command)->
        current = @data.getCurrent()
        return if @duplicateField command, current, 'documentationUrl'
        return if @missingArgText command

        current.documentationUrl = command.argText

    _command_description: (command)->
        current = @data.getCurrent()
        return if @duplicateField command, current, 'description'
        return if @missingArgText command

        current.description = command.argText

    _command_name: (command)->
        current = @data.getCurrent()
        return if @duplicateField command, current, 'name'
        return if @missingArgText command

        current.name = command.argText
