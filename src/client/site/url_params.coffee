#
# Crafting Guide - storage.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

url = require 'url'

########################################################################################################################

module.exports = class UrlParams

    constructor: (parseMap, url=null)->
        if not parseMap? then throw new Error 'parseMap is required'
        url ?= window.location.href

        @_parseMap = {}
        for name, options of parseMap
            options.type ?= 'string'
            options.default ?= null

            options.parse = this["_#{options.type}"]
            if not options.parse? then throw new Error "#{options.type} is not a valid type"

            @_parseMap[name] = options

        @parse url

    parse: (urlText)->
        params = url.parse(urlText, true).query
        for name, options of @_parseMap
            value = params[name]
            if value?
                this[name] = options.parse value
            else
                this[name] = options.default

    # Private Methods ##############################################################################

    _boolean: (text)->
        return true if text in ['true', 'yes']
        return false

    _integer: (text)->
        return null unless text?
        result = parseInt text
        return null unless _.isNumber result
        return result

    _string: (text)->
        return text
