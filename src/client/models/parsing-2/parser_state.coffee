#
# Crafting Guide - parser_state.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class ParserState

    constructor: ->
        @clear()

    # Public Methods ###############################################################################

    addError: (command, message)->
        if not command? then throw new Error 'command is required'
        message ?= 'is not valid'
        @_errors.push command:command, message:message

    create: (command, type, id=null)->
        id ?= _.uniqueId "#{type}-"

        typeData = @_findOrCreateType type
        itemData = @_current = typeData['current'] = typeData[id] = id:id, command:command, type:type
        return itemData

    clear: ->
        @_current = null
        @_data = {}
        @_errors = []

    each: (callback)->
        for type, typeData of @_data
            for id, itemData of typeData
                continue if id is 'current'
                continue if id is 'type'
                callback itemData

    eachOfType: (type, callback)->
        typeData = @_findOrCreateType type
        for id, itemData of typeData
            continue if id is 'current'
            continue if id is 'type'
            callback itemData

    get: (type, id)->
        typeData = @_findOrCreateType type
        itemData = typeData[id] or null
        return itemData

    getCurrent: (type)->
        return @_current unless type?

        typeData = @_findOrCreateType type
        current = typeData['current'] or null
        return current

    # Property Methods #############################################################################

    getErrors: ->
        return @_errors[..]

    Object.defineProperties @prototype,
        errors: { get:@::getErrors }

    # Private Methods ##############################################################################

    _findOrCreateType: (type)->
        typeData = @_data[type]
        if not typeData?
            typeData = @_data[type] = {}
            typeData.type = type

        return typeData
