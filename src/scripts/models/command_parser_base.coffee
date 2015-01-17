###
Crafting Guide - command_parser_base.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class CommandParserBase

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.showAllErrors ?= false

        @_model         = options.model
        @_showAllErrors = options.showAllErrors

    # Class Methods ################################################################################

    @COMMAND = /\ *([^:]*):?(.*)/

    @COMMENT = /([^\\]?)#.*/

    # Public Methods ###############################################################################

    parse: (text)->
        @_rawData    = {}
        @_lineNumber = 1

        lines = text.split '\n'
        for i in [0...lines.length]
            @_lineNumber = i + 1
            commands = @_parseLine lines[i]
            for command in commands
                @_handleErrors @_execute, command

        @_handleErrors @_buildModel, @_rawData, @_model
        return @_model

    unparse: ->
        builder = new StringBuilder context:@model
        @_unparseModel builder, model
        return builder.toString()

    # Subclass Methods #############################################################################

    _buildModel: (rawData, model)->
        throw new Error 'Subclasses must override this method'

    _unparseModel: (builder, model)->
        throw new Error 'Subclasses must override this method'

    # Private Methods ##############################################################################

    _execute: (command)->
        method = this["_command_#{command.name}"]
        if not method? then throw new Error "Unknown command: #{command.name}"

        @_handleErrors method, command.args

    _parseLine: (line)->
        line = line.replace CommandParserBase.COMMENT, '$1'
        line = line.trim()
        return [] if line.length is 0

        lineParts = (part.trim() for part in line.split(';'))
        commands = []
        for linePart in lineParts
            continue if linePart.length is 0

            match = CommandParserBase.COMMAND.exec linePart
            if not match? then throw new Error "Expected <command>: <args>, but found: \"#{linePart}\""

            args = []
            args = (s.trim() for s in match[2].split(',')) if match[2]?
            commands.push name:match[1], args:args

        return commands

    _handleErrors: (callback, args...)->
        if args.length is 1 and _.isArray(args[0]) then args = args[0]

        try
            callback.apply this, args
        catch e
            e.message = "line #{@_lineNumber}: #{e.message}"
            if not @_showAllErrors then throw e
            logger.error e.message
