#
# Crafting Guide - item_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class ItemParserExtensionV1 extends ParserExtension

    constructor: (data)->
        super data, 'item',
            gatherable: @_command_gatherable
            item:       @_command_item
            update:     @_command_update

    # ParserExtensions Overrides ###################################################################

    assmeble: (entry)->
        throw new Error "#{@constructor.name} must override the `assemble` method"

    build: (entry)->
        entry.instance = new
        throw new Error "#{@constructor.name} must override the `build` method"

    validate: (entry)-> # do nothing

    # Command Methods ##############################################################################

    _command_gatherable: (command)->
        return if @missingArgText command
        return if @missingCurrent command, 'item'

        item = @data.getCurrent 'item'
        return if @duplicateField command, item, 'gatherable'

        gatherable = @parseBoolean command, command.argText
        return unless gatherable?

        item.gatherable = gatherable

    _command_item: (command)->
        return if @missingArgText command
        return if @missingCurrent command, 'modVersion'
        return if @alreadyExists command, 'item', command.argText

        item = @data.create command, 'item', command.argText
        item.name = command.argText
        item.isUpdate = false

        group = @data.getCurrent 'itemGroup'
        if group? then item.group = group

        item.modVersion = @data.getCurrent 'modVersion'

    _command_update: (command)->
        return if @missingArgText command
        return if @missingCurrent command, 'modVersion'
        return if @alreadyExists command, 'item', command.argText

        item = @data.create command, 'item', command.argText
        item.name = command.argText
        item.isUpdate = true
        item.modVersion = @data.getCurrent 'modVersion'
