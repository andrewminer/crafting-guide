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

    load: (key)->
        value = @storage.getItem key
        logger.verbose "loaded #{value} from #{key}"
        return value

    store: (key, value)->
        @storage.setItem key, value
        logger.verbose "stored #{value} into #{key}"

    register: (key, model, properties...)->
        modelData = @_models[key]
        if not modelData? then modelData = @_models[key] = model:model, properties:{}
        makeStoreMethod = (k, m, p)=> return => @_storeProperty(k, m, p)

        for property in properties
            continue if modelData.properties[property]?
            modelData.properties[property] = property

            @_loadProperty key, model, property
            model.on "change:#{property}", makeStoreMethod(key, model, property)

    unregister: (key, property)->
        modelData = @_models[key]
        return unless modelData?
        delete modelData.properties[key]

    # Private Methods ##############################################################################

    _loadProperty: (key, model, property)->
        value = @load "#{key}:#{property}"
        value = JSON.parse(value) if value?
        return unless value?

        model[property] = value

    _storeProperty: (key, model, property)->
        value = JSON.stringify model[property]
        @store "#{key}:#{property}", value
