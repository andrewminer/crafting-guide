#
# Crafting Guide - lexical_analyzer.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserCommand = require './parser_command'

########################################################################################################################

module.exports = class LexicalAnalyzer

    constructor: (fileName, rawText)->
        if not fileName? then throw new Error 'fileName is required'
        if not rawText? then throw new Error 'rawText is required'

        @_commands   = []
        @_fileName   = fileName
        @_rawText    = rawText
        @_lines      = rawText.split '\n'
        @_lineIndex  = -1
        @_lineNumber = 0

    # Class Methods ################################################################################

    @::COMMAND = /\ *([^:]*):?(.*)/

    @::COMMENT = /([^\\]?)#.*/

    @::FILE = /^#FILE +(.*)/

    # Public Methods ###############################################################################

    next: ->
        command = @peek()
        @_commands.shift()
        return command

    peek: ->
        while @_commands.length is 0
            break if @_lineNumber > @_lines.length
            @_parseLine()

        return null unless @_commands.length > 0
        return @_commands[0]

    push: (command)->
        @_commands.unshift command

    # Property Methods #############################################################################

    getIsFinished: ->
        return @peek() is null

    Object.defineProperties @prototype,
        isFinished: { get:@::getIsFinished }

    # Private Methods ##############################################################################

    _currentLine: ->
        return null if @_lineIndex >= @_lines.length
        return @_lines[@_lineIndex]

    _nextLine: ->
        if @_lineIndex < @_lines.length
            while true
                @_lineIndex += 1
                @_lineNumber += 1
                break if @_lineIndex >= @_lines.length

                line = @_lines[@_lineIndex]

                fileMatch = line.match @FILE, '$1'
                if fileMatch?
                    @_fileName = fileMatch[1]
                    @_lineNumber = 0
                else
                    line = line.replace @COMMENT, '$1'
                    @_lines[@_lineIndex] = line

                    break if line.trim().length > 0

        return @_currentLine()

    _parseHereDoc: ->
        line = @_currentLine()
        hereDocIndex = line.indexOf '<<-'
        return [line, null] unless hereDocIndex isnt -1

        hereDocStopText = line[hereDocIndex+3...line.length]
        line = line[0...hereDocIndex]

        hereDocLines = []
        while true
            nextLine = @_nextLine()
            break unless nextLine?
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

    _parseLine: ->
        line = @_nextLine()
        return unless line?

        startingLineNumber = @_lineNumber
        [line, lineHereDoc] = @_parseHereDoc()

        lineParts = (part.trim() for part in line.split(';'))
        for linePart, index in lineParts
            continue if linePart.length is 0

            hereDoc = lineHereDoc if index is lineParts.length - 1

            match = @COMMAND.exec linePart
            if not match? then throw new Error "Expected <command>: <args>, but found: \"#{linePart}\""

            argText = if match[2] then match[2].trim() else ''
            args = (arg.trim() for arg in argText.split(','))
            args = (arg for arg in args when arg.length > 0)

            if hereDoc?
                if argText.length > 0 then argText += ', '
                argText += hereDoc
                args.push hereDoc

            @_commands.push new ParserCommand
                argText:    argText
                args:       args
                fileName:   @_fileName
                hereDoc:    hereDoc
                lineNumber: startingLineNumber
                name:       match[1]
