#
# Crafting Guide - item_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class ItemParserExtensionV1 extends ParserExtension

    # Command Methods ##############################################################################

    _command_gatherable: (command)->
        return if @missingArgText command

        return if @missingCurrent command, 'item'

        item = @state.getCurrent 'item'
        return if @duplicateField command, 'gatherable', item

        gatherable = @parseBoolean command, command.argText
        return unless gatherable?

        item.gatherable = gatherable

    _command_item: (command)->
        return if @missingArgText command
        return if @missingCurrent command, 'modVersion'
        return if @alreadyExists command, 'item', command.argText

        item = @state.create command, 'item', command.argText
        item.name = command.argText

        group = @state.getCurrent 'itemGroup'
        if group? then item.group = group

        item.modVersion = @state.getCurrent 'modVersion'
