###
Crafting Guide - storage.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class Storage

    constructor: (options={})->
        options.storage ?= window.sessionStorage

        @storage = options.storage
        @_models = {}

    # Public Methods ###############################################################################

    register: (key, model, properties...)->
        modelData = @_models[key]
        if not modelData? then modelData = @_models[key] = model:model, properties:{}
        makeStoreMethod = (k, m, p)=> return => @_store(k, m, p)

        for property in properties
            continue if modelData.properties[property]?
            modelData.properties[property] = property

            @_load key, model, property
            model.on "change:#{property}", makeStoreMethod(key, model, property)

    unregister: (key, property)->
        modelData = @_models[key]
        return unless modelData?
        delete modelData.properties[key]

    # Private Methods ##############################################################################

    _load: (key, model, property)->
        value = @storage.getItem "#{key}:#{property}"
        value = JSON.parse(value) if value?

        logger.verbose "loaded #{value} from #{key}:#{property}"
        return unless value?

        model[property] = value

    _store: (key, model, property)->
        value = JSON.stringify model[property]
        @storage.setItem "#{key}:#{property}", value
        logger.verbose "stored #{value} into #{key}:#{property}"
