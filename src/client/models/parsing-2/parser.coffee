#
# Crafting Guide - parser.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

LexicalAnalyzer = require './lexical_analyzer'
ModPack         = require '../game/mod_pack'
ParserData      = require './parser_data'

########################################################################################################################

module.exports = class Parser

    constructor: (modPack, fileName, rawText)->
        @_extensions = []
        @_fileName   = fileName
        @_lexer      = new LexicalAnalyzer fileName, rawText
        @_modPack    = new ModPack
        @_data       = new ParserData

        modPackData = @_data.create {}, 'modPack'
        modPackData.instance = @_modPack

        @_loadSchema()

    # Public Methods ###############################################################################

    next: ->
        if not @_lexer.isFinished
            @_processNextCommand()
        else if not @_data.isValidated
            @_validateNextEntry()
        else if not @_data.isBuilt
            @_buildNextEntry()
        else if not @_data.isAssembled
            @_assembleNextEntry()

    # Property Methods #############################################################################

    getIsFinished: ->
        return @_lexer.isFinished and @_data.isValidated and @_data.isBuilt and @_data.isAssembled

    getData: ->
        return @_data

    getModPack: ->
        return @_modPack

    Object.defineProperties @prototype,
        data: { get:@::getData }
        isFinished: { get:@::getIsFinished }
        modPack: { get:@::getModPack }

    # Private Methods ##############################################################################

    _assembleNextEntry: ->
        entry = @_data.popNextToAssemble()
        return unless entry?

        for extensions in @_extensions
            continue unless extension.canAssemble entry
            extension.assemble entry
            return

    _buildNextEntry: ->
        entry = @_data.popNextToBuild()
        return unless entry?

        for extensions in @_extensions
            continue unless extension.canBuild entry
            extension.build entry
            return

    _loadSchema: ->
        command = @_lexer.next()
        if command.name isnt 'schema' then throw new Error "#{@_fileName} must start with the \"schema\" command"

        schema = command.argText
        if schema is '1'
            @_use new require './parser_extensions/current_pe_v1'
            @_use new require './parser_extensions/item_pe_v1'
            @_use new require './parser_extensions/mod_pe_v1'
            @_use new require './parser_extensions/mod_version_pe_v1'
            @_use new require './parser_extensions/recipe_pe_v1'
        else
            throw new Error "unknown schema version: #{schema}"

    _processNextCommand: ->
        command = @_lexer.next()
        return unless command?

        for extension in @_extensions
            continue unless extension.canExecute command
            extension.execute command
            return

        @_data.addError command, "unknown command: #{command.name}"

    _use: (parserExtension)->
        parserExtension.state = @_state
        @_extensions.push parserExtension

    _validateNextEntry: ->
        entry = @_data.popNextToValidate()
        return unless entry?

        for extensions in @_extensions
            continue unless extension.canValidate entry
            extension.validate entry
            return
