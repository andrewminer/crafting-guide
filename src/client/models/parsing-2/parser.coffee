#
# Crafting Guide - parser.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

LexicalAnalyzer = require './lexical_analyzer'
ParserState     = require './parser_state'

########################################################################################################################

module.exports = class Parser

    constructor: (state, fileName, rawText)->
        if not state? then throw new Error 'state is required'

        @_extensions = []
        @_fileName   = fileName
        @_lexer      = new LexicalAnalyzer fileName, rawText
        @_state      = state

        @_loadSchema()

    # Public Methods ###############################################################################

    processNextCommand: w.lift ->
        command = @_lexer.next()
        return unless command?

        for extension in @_extensions
            continue unless extension.accepts command
            extension.execute command
            return

        throw new Error "unknown command: #{command.name}"

    # Property Methods #############################################################################

    getIsFinished: ->
        return @_lexer.isFinished

    getState: ->
        return @_state

    Object.defineProperties @prototype,
        isFinished: { get:@::getIsFinished }
        state: { get:@::getState }

    # Private Methods ##############################################################################

    _loadSchema: ->
        command = @_lexer.next()
        if command.name isnt 'schema' then throw new Error "#{@_fileName} must start with the \"schema\" command"

        schema = command.argText
        if schema is '1'
            @_use new require './parser_extensions/current_pe_v1'
            @_use new require './parser_extensions/mod_pe_v1'
            @_use new require './parser_extensions/mod_version_pe_v1'
        else
            throw new Error "unknown schema version: #{schema}"

    _use: (parserExtension)->
        parserExtension.state = @_state
        @_extensions.push parserExtension
