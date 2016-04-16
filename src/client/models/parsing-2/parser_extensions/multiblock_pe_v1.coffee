#
# Crafting Guide - multiblock_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class MultiblockParserExtensionV1 extends ParserExtension

    constructor: (data)->
        super data, 'multiblock',
            layer:      @_command_layer
            multiblock: @_command_multiblock

    # Command Methods ##############################################################################

    _command_layer: (command)->
        return if @missingCurrent command, 'multiblock'
        return if @missingArgText command

        multiblock = @data.getCurrent 'multiblock'
        multiblock.layers ?= []
        multiblock.layers.push command.argText

    _command_multiblock: (command)->
        return if @missingCurrent command, 'item'

        item = @data.getCurrent 'item'
        return if @duplicateField command, item, 'multiblock'
        return if @incompatibleField command, item, 'recipe'
        return if @incompatibleField command, item, 'gatherable'

        multiblock = @data.create command, 'multiblock'
        multiblock.item = item
