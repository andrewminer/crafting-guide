#
# Crafting Guide - storage.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class Storage

    constructor: (options={})->
        options.storage ?= window.sessionStorage

        @storage = options.storage
        @_models = {}

    # Public Methods ###############################################################################

    load: (key)->
        value = @storage.getItem key
        logger.verbose -> "loaded #{value} from #{key}"
        return value

    store: (key, value)->
        @storage.setItem key, value
        logger.verbose -> "stored #{value} into #{key}"

    register: (key, model, property, defaultValue=null)->
        modelData = @_models[key]
        if not modelData? then modelData = @_models[key] = model:model, properties:{}
        makeStoreMethod = (k, m, p)=> return => @_storeProperty(k, m, p)

        return if modelData.properties[property]?
        modelData.properties[property] = property

        @_loadProperty key, model, property, defaultValue
        model.on "change:#{property}", makeStoreMethod(key, model, property)

    unregister: (key, property)->
        modelData = @_models[key]
        return unless modelData?
        delete modelData.properties[key]

    # Private Methods ##############################################################################

    _loadProperty: (key, model, property, defaultValue=null)->
        loadedValue = @load "#{key}:#{property}"
        if loadedValue?
            value = JSON.parse loadedValue
        else
            value = defaultValue

        return unless value?
        model[property] = value

        if value? and not loadedValue?
            @_storeProperty key, model, property

    _storeProperty: (key, model, property)->
        value = JSON.stringify model[property]
        @store "#{key}:#{property}", value
