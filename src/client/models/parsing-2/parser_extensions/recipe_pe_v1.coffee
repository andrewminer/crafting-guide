#
# Crafting Guide - recipe_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class RecipeParserExtensionV1 extends ParserExtension

    constructor: (data)->
        super data, 'recipe',
            extras:   @_command_extras
            input:    @_command_input
            pattern:  @_command_pattern
            recipe:   @_command_recipe
            quantity: @_command_quantity
            tools:    @_command_tools

    # Class Methods ################################################################################

    @::PATTERN = /[0-9. ]+/

    @::STACK = /^([0-9]+) +(.+)$/

    # Error Checking Helpers #######################################################################

    invalidPattern: (command)->
        match = command.argText.match @PATTERN
        if not match?
            @data.addError command, "invalid pattern: \"#{command.argText}\""
            return true

        return false

    # Command Methods ##############################################################################

    _command_extras: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgs command

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, 'extras', recipe

        recipe.extras = command.args

    _command_input: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgs command

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, 'input', recipe

        recipe.input = (@_parseStack(arg) for arg in command.args)

    _command_pattern: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgText command
        return if @invalidPattern command

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, 'pattern', recipe

        recipe.pattern = command.argText

    _command_recipe: (command)->
        return if @missingCurrent command, 'item'

        recipe = @data.create command, 'recipe'
        recipe.item = @data.getCurrent 'item'

    _command_quantity: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgText command

        value = @parseInt command, command.argText
        return unless value?

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, 'quantity', recipe

        recipe.quantity = value

    _command_tools: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgs command

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, 'tools', recipe

        recipe.tools = (@_parseStack(arg) for arg in command.args)

    # Custom Parsers ###############################################################################

    _parseStack: (text)->
        match = text.match @STACK
        return name:text, quantity:1 unless match?

        quantity = parseFloat match[1]
        if isNaN quantity then quantity = 1

        name = match[2]

        return name:name, quantity:quantity
