#
# Crafting Guide - parser_extension.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class ParserExtension

    constructor: (data, type, commandFunctions)->
        @data = data

        @_commandFunctions = commandFunctions or {}
        @_type             = type or null

    # Public Methods ###############################################################################

    canAssemble: (entry)->
        return entry.type is @_type

    canBuild: (entry)->
        return entry.type is @_type

    canExecute: (command)->
        _.isFunction @_commandFunctions[command.name]

    canValidate: (entry)->
        return entry.type is @_type

    execute: (command)->
        if not @_data? then throw new Error '@data must be defined before executing commands'

        func = @_commandFunctions[command.name]
        if not func then throw new Error "#{@constructor.name} cannot handle command: #{command.name}"

        func.call this, command
        return this

    # Error Checking Helpers #######################################################################

    alreadyExists: (command, type, id)->
        obj = @data.get(type, id)
        if obj?
            @data.addError command, "a #{type} called #{id} has already been declared"
            return true

        return false

    duplicateField: (command, obj, field)->
        if obj[field]?
            @data.addError command, "duplicate #{field}"
            return true

        return false

    incompatibleField: (command, obj, field, otherCommandName)->
        otherCommandName ?= field
        if obj[field]?
            @data.addError "#{command.name} cannot be used with #{otherCommandName}"
            return true

        return false

    missingCurrent: (command, type)->
        obj = @data.getCurrent type
        if not obj?
            @data.addError command, "you must declare a #{type} before using #{command.name}"
            return true

        return false

    missingArgs: (command)->
        if not command.args or command.args.length is 0
            @data.addError command, "#{command.name} requires at least one item"
            return true

        return false

    missingArgText: (command)->
        if command.argText.length is 0
            @data.addError command, "#{command.name} cannot be empty"
            return true

        return false

    invalidVerb: (command, verb)->
        if not verb in ['mod', 'item']
            @data.addError command, "#{command.name} only applies to either `mod` or `item`"
            return true

        return false

    tooFewArguments: (command, minimum)->
        if command.args.length < minimum
            @data.addError command, "#{command.name} requires at least #{minimum} arguments"
            return true

        return false

    # Parsing Helpers ##############################################################################

    parseBoolean: (command, text)->
        return null unless text?

        switch text.toLowerCase()
            when "yes" then return true
            when "no" then return false

        @data.addError command, "#{command.name} requires \"yes\" or \"no\""
        return null

    parseInt: (command, text)->
        return null unless text?

        value = Number.parseInt text
        if isNaN value
            @addError command, "#{command.name} requires a number"
            return null

        return value

    # Property Methods #############################################################################

    getData: ->
        return @_data

    setData: (data)->
        if not data? then throw new Error 'data cannot be undefined'
        @_data = data

    Object.defineProperties @prototype,
        data: { get:@::getData, set:@::setData }

    # Overridable Methods ##########################################################################

    assmeble: (entry)->
        throw new Error "#{@constructor.name} must override the `assemble` method"

    build: (entry)->
        throw new Error "#{@constructor.name} must override the `build` method"

    validate: (entry)->
        throw new Error "#{@constructor.name} must override the `validate` method"

    # Private Methods ##############################################################################

    _findBuildMethod: (entry)->
        methodName = "_build_#{entry.type}"
        method = this[methodName]
        return null unless _.isFunction method
        return method

    _findCommandMethod: (command)->
        methodName = "_command_#{command.name}"
        method = this[methodName]
        return null unless _.isFunction method
        return method

    _findValidateMethod: (command)->
        methodName = "_validate_#{command.name}"
        method = this[methodName]
        return null unless _.isFunction method
        return method
