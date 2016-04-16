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
            extras:               @_command_extras
            ignoreDuringCrafting: @_command_ignoreDuringCrafting
            input:                @_command_input
            onlyIf:               @_command_onlyIf
            pattern:              @_command_pattern
            recipe:               @_command_recipe
            quantity:             @_command_quantity
            tools:                @_command_tools

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

    _command_ignoreDuringCrafting: (command)->
        return if @missingArgText command
        return if @missingCurrent command, 'recipe'

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, recipe, 'ignoreDuringCrafting'

        ignoreDuringCrafting = @parseBoolean command, command.argText
        return unless ignoreDuringCrafting?

        recipe.ignoreDuringCrafting = ignoreDuringCrafting

    _command_input: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgs command

        recipe = @data.getCurrent 'recipe'
        multiblock = @data.getCurrent 'multiblock'

        target = if multiblock? then multiblock else recipe

        return if @duplicateField command, 'input', target
        target.input = (@_parseStack(arg) for arg in command.args)

    _command_onlyIf: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgText command

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, recipe, 'condition'

        words = command.argText.split ' '
        inverted = false
        if words[0] is 'not'
            inverted = true
            words.shift()

        verb = words[0]
        noun = words[1..].join ' '

        return if @invalidVerb command, verb
        recipe.condition = verb:verb, noun:noun, inverted:inverted

    _command_pattern: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgText command
        return if @invalidPattern command

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, 'pattern', recipe

        recipe.pattern = command.argText

    _command_quantity: (command)->
        return if @missingCurrent command, 'recipe'
        return if @missingArgText command

        value = @parseInt command, command.argText
        return unless value?

        recipe = @data.getCurrent 'recipe'
        return if @duplicateField command, 'quantity', recipe

        recipe.quantity = value

    _command_recipe: (command)->
        return if @missingCurrent command, 'item'

        recipe = @data.create command, 'recipe'
        recipe.item = @data.getCurrent 'item'

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
