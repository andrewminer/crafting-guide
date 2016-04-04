#
# Crafting Guide - command_parser_version_base.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

{StringBuilder} = require 'crafting-guide-common'

########################################################################################################################

module.exports = class CommandParserVersionBase

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.showAllErrors ?= false

        @_model         = options.model
        @_showAllErrors = options.showAllErrors
        @errors         = []

    # Class Methods ################################################################################

    @COMMAND = /\ *([^:]*):?(.*)/

    @COMMENT = /([^\\]?)#.*/

    @simplify: (text)->
        text = text.trim()
        text = text.replace /\  */g , ' '
        text = text.replace /\n/g, ';'
        text = text.replace /; */g, ';'
        text = text.replace /;;*/g, ';'
        text = text.replace /: /g, ':'
        return text

    # Public Methods ###############################################################################

    parse: (text)->
        @_rawData    = {}
        @_lineNumber = 1
        @errors      = []

        @_lines = text.split '\n'
        @_lineNumber = 0
        while @_lineNumber < @_lines.length
            @_lineNumber += 1
            commands = @_parseLine @_lines[@_lineNumber - 1]
            for command in commands
                @_handleErrors @_execute, command

        @_handleErrors @_buildModel, @_rawData, @_model
        return @_model

    unparse: ->
        builder = new StringBuilder context:@_model
        @_unparseModel builder, @_model
        return builder.toString()

    # Subclass Methods #############################################################################

    _buildModel: (rawData, model)->
        throw new Error 'Subclasses must override this method'

    _unparseModel: (builder, model)->
        throw new Error 'Subclasses must override this method'

    _command_schema: -> # do nothing

    # Private Methods ##############################################################################

    _execute: (command)->
        method = this["_command_#{command.name}"]
        if not method? then throw new Error "Unknown command: #{command.name}"

        @_handleErrors method, command.args

    _parseLine: (line)->
        line = line.replace CommandParserVersionBase.COMMENT, '$1'
        line = line.trim()
        return [] if line.length is 0

        [line, hereDoc] = @_parseHereDoc line

        lineParts = (part.trim() for part in line.split(';'))
        commands = []
        for linePart in lineParts
            continue if linePart.length is 0

            match = CommandParserVersionBase.COMMAND.exec linePart
            if not match? then throw new Error "Expected <command>: <args>, but found: \"#{linePart}\""

            args = []
            args = (s for s in match[2].split(',') when s.length > 0) if match[2]?
            args = (s.trim() for s in args)
            args = (s for s in args when s.length > 0)
            args.push hereDoc if hereDoc?
            commands.push name:match[1], args:args

        return commands

    _handleErrors: (callback, args...)->
        if args.length is 1 and _.isArray(args[0]) then args = args[0]

        try
            callback.apply this, args
        catch e
            e.message = "line #{@_lineNumber}: #{e.message}"
            if not @_showAllErrors then throw e
            @errors.push e
            logger.error -> e.message

    _parseHereDoc: (line)->
        hereDocIndex = line.indexOf '<<-'
        return [line, null] unless hereDocIndex isnt -1

        hereDocStopText = line[hereDocIndex+3...line.length]
        line = line[0...hereDocIndex]

        hereDocLines = []
        while true
            @_lineNumber += 1
            break if @_lineNumber >= @_lines.length

            nextLine = @_lines[@_lineNumber-1]
            break if nextLine.trim() is hereDocStopText
            hereDocLines.push nextLine

        shortestIndent = Number.MAX_VALUE
        for hereDocLine in hereDocLines
            continue if hereDocLine.trim().length is 0
            shortestIndent = Math.min hereDocLine.match(/( *).*/)[1].length, shortestIndent

        for i in [0...hereDocLines.length]
            hereDocLines[i] = hereDocLines[i][shortestIndent..]

        return [line, null] unless hereDocLines.length > 0
        return [line, hereDocLines.join('\n')]
