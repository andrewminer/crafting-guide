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
            description: @_command_description
            name:        @_command_name
            officialUrl: @_command_officialUrl
            video:       @_command_video

    # Command Methods ##############################################################################

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

    _command_officialUrl: (command)->
        current = @data.getCurrent()
        return if @duplicateField command, current, 'officialUrl'
        return if @missingArgText command

        current.officialUrl = command.argText

    _command_video: (command)->
        current = @data.getCurrent()
        return if @missingArgs command
        return if @tooFewArguments command, 2

        current.videos ?= []
        current.videos.push youTubeId:command.args[0], caption:command.args[1..].join(', ')
