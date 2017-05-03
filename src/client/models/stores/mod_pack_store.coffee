#
# Crafting Guide - mod_pack_store.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ModPackJsonParser = require "../parsing/mod_pack_json_parser"
w                 = require "when"

########################################################################################################################

module.exports = class ModPackStore

    constructor: ->
        @_data    = {}
        @_loading = {}
        @_parser  = new ModPackJsonParser

    # Class Methods ################################################################################

    Object.defineProperties ModPackStore,
        instance:
            get: ->
                @_instance ?= new ModPackStore
                return @_instance
            set: ->
                throw new Error "cannot assign instance"

    # Public Methods ###############################################################################

    get: (modPackId)->
        return @_data[modPackId]

    load: (modPackId)->
        if not @_loading[modPackId]?
            @_loading[modPackId] = w.promise (resolve, reject)->
                url = c.url.modPackArchive modPackId:modPackId

                onError = (xhr, status, message)=>
                    logger.error "failed to load mod pack #{modPackId}: #{status} — #{message}"
                    reject new Error message

                onSuccess = (data, status, xhr)=>
                    logger.info "laoded mod pack: #{modPackId}"
                    try
                        @_parser.reset()
                        modPack = @_parser.parse data, url
                        @_data[modPack.id] = modPack
                        resolve modPack
                    catch error
                        reject error

                $.ajax dataType: "text", error: onError, success: onSuccess, url: url

        return @_loading[modPackId]
