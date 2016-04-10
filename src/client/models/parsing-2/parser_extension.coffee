#
# Crafting Guide - parser_extension.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class ParserExtension

    constructor: (state)->
        @state = state

    # Public Methods ###############################################################################

    accepts: (command)->
        return @_findCommandMethod(command)?

    execute: w.lift (command)->
        if not @_state? then throw new Error '@state must be defined before executing commands'

        method = @_findCommandMethod command
        method.call this, command

    # Error Checking Helpers #######################################################################

    alreadyExists: (command, type, id)->
        obj = @state.get(type, id)
        if obj?
            @state.addError command, "a #{type} called #{id} has already been declared"
            return true

        return false

    duplicateField: (command, obj, field)->
        if obj[field]?
            @state.addError command, "duplicate #{field}"
            return true

        return false

    missingCurrent: (command, type)->
        obj = @state.getCurrent type
        if not obj?
            @state.addError command, "you must declare a #{type} before using #{command.name}"
            return true

        return false

    missingArgs: (command)->
        if not command.args or command.args.length is 0
            @state.addError command, "#{command.name} requires at least one item"
            return true

        return false

    missingArgText: (command)->
        if command.argText.length is 0
            @state.addError command, "#{command.name} cannot be empty"
            return true

        return false

    # Parsing Helpers ##############################################################################

    parseBoolean: (command, text)->
        return null unless text?

        switch text.toLowerCase()
            when "yes" then return true
            when "no" then return false

        @state.addError command, "#{command.name} requires \"yes\" or \"no\""
        return null

    parseInt: (command, text)->
        return null unless text?

        value = Number.parseInt text
        if isNaN value
            @addError command, "#{command.name} requires a number"
            return null

        return value

    # Property Methods #############################################################################

    getState: ->
        return @_state

    setState: (state)->
        if not state? then throw new Error 'state cannot be undefined'
        @_state = state

    Object.defineProperties @prototype,
        state: { get:@::getState, set:@::setState }

    # Private Methods ##############################################################################

    _findCommandMethod: (command)->
        methodName = "_command_#{command.name}"
        method = this[methodName]
        return null unless _.isFunction(method)
        return method
