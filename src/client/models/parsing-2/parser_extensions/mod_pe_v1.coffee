#
# Crafting Guide - mod_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class ModParserExtensionV1 extends ParserExtension

    constructor: (data)->
        super data, 'mod',
            author:           @_command_author
            documentationUrl: @_command_documentationUrl
            downloadUrl:      @_command_downloadUrl
            homePageUrl:      @_command_homePageUrl
            mod:              @_command_mod

    # Command Methods ##############################################################################

    _command_author: (command)->
        return if @missingCurrent command, 'mod'

        mod = @data.getCurrent 'mod'
        return if @duplicateField command, mod, 'author'
        return if @missingArgText command

        mod.author = command.argText

    _command_documentationUrl: (command)->
        current = @data.getCurrent()
        return if @duplicateField command, current, 'documentationUrl'
        return if @missingArgText command

        current.documentationUrl = command.argText

    _command_downloadUrl: (command)->
        return if @missingCurrent command, 'mod'

        mod = @data.getCurrent 'mod'
        return if @duplicateField command, mod, 'downloadUrl'
        return if @missingArgText command

        mod.downloadUrl = command.argText

    _command_homePageUrl: (command)->
        return if @missingCurrent command, 'mod'

        mod = @data.getCurrent 'mod'
        return if @duplicateField command, mod, 'homePageUrl'
        return if @missingArgText command

        mod.homePageUrl = command.argText

    _command_mod: (command)->
        return if @missingArgText command
        return if @alreadyExists command, 'mod', command.argText

        @data.create command, 'mod', command.argText