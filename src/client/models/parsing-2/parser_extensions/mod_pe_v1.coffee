#
# Crafting Guide - mod_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class ModParserExtensionV1 extends ParserExtension

    # Command Methods ##############################################################################

    _command_author: (command)->
        return if @missingCurrent command, 'mod'

        mod = @state.getCurrent 'mod'
        return if @duplicateField command, mod, 'author'
        return if @missingArgText command

        mod.author = command.argText

    _command_downloadUrl: (command)->
        return if @missingCurrent command, 'mod'

        mod = @state.getCurrent 'mod'
        return if @duplicateField command, mod, 'downloadUrl'
        return if @missingArgText command

        mod.downloadUrl = command.argText

    _command_homePageUrl: (command)->
        return if @missingCurrent command, 'mod'

        mod = @state.getCurrent 'mod'
        return if @duplicateField command, mod, 'homePageUrl'
        return if @missingArgText command

        mod.homePageUrl = command.argText

    _command_mod: (command)->
        return if @missingArgText command
        return if @alreadyExists command, 'mod', command.argText

        @state.create command, 'mod', command.argText
