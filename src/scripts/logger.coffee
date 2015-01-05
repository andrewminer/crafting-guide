###
Crafting Guide - logger.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class Logger

    @TRACE   = {name:'TRACE  ', value:0}
    @DEBUG   = {name:'DEBUG  ', value:1}
    @VERBOSE = {name:'VERBOSE', value:2}
    @INFO    = {name:'INFO   ', value:3}
    @WARNING = {name:'WARNING', value:4}
    @ERROR   = {name:'ERROR  ', value:5}
    @FATAL   = {name:'FATAL  ', value:6}

    ALL_LEVELS = [@TRACE, @DEBUG, @VERBOSE, @INFO, @WARNING, @ERROR, @FATAL]

    constructor: (options={})->
        options.level ?= Logger.FATAL
        @formatText = if options.format? then options.format else "<%= timestamp %> | <%= level %> | <%= message %>"
        @level      = @_parseLevel options

        @_format   = _.template @formatText

    log: (level, message)->
        return unless level.value >= @level.value
        message = message() if _.isFunction message

        entry = {timestamp:new Date(), level:level, message:message}
        entry.level ?= @level

        lines = @_formatEntry entry
        if entry.level.value < Logger.WARNING.value
            console.log(line) for line in lines
        else
            console.error(line) for line in lines

    # Log Methods ##################################################################################

    trace: (message)-> @log Logger.TRACE, message

    debug: (message)-> @log Logger.DEBUG, message

    verbose: (message)-> @log Logger.VERBOSE, message

    info: (message)-> @log Logger.INFO, message

    warning: (message)-> @log Logger.WARNING, message

    error: (message)->
        message = "#{message.stack}" if message.stack?
        @log Logger.ERROR, message

    fatal: (message)-> @log Logger.FATAL, message

    # Private Methods ##############################################################################

    _formatEntry: (entry, lines=[])->
        message = entry.message.replace /\\n/g, '\n'
        for line in message.split '\n'
            result = []
            result.push @_format
                timestamp: "#{entry.timestamp}"
                level:     entry.level.name
                message:   line
            lines.push result.join ''
        return lines

    _parseLevel: (options)->
        return Logger.FATAL unless _(options).has 'level'
        level = options.level

        if not level?
            candidates = []
        else if _.isString level
            candidates = (l for l in ALL_LEVELS when l.name.trim().toLowerCase() is level.trim().toLowerCase())
        else if _.isNumber level
            candidates = (l for l in ALL_LEVELS when l.value is level)
        else if level?
            candidates = (l for l in ALL_LEVELS when l is level)

        throw new Error "invalid level: #{level}" unless candidates.length > 0
        return candidates[0]
