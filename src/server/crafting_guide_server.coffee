#
# Crafting Guide - crafting_guide_server.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express    = require 'express'
http       = require 'http'
middleware = require './middleware'
routes     = require './routes'

############################################################################################################

module.exports = class CraftingGuideServer

    constructor: (port)->
        if not port? then throw new Error 'port is mandatory'
        if not _.isNumber port then throw new Error 'port must be a number'
        @port = parseInt port

        app = express()
        app.disable 'etag'

        middleware.installBefore app
        app.use routes
        middleware.installAfter app

        @httpServer = http.createServer app

    start: ->
        w.promise (resolve, reject)=>
            @httpServer.once 'error', (error)-> reject error
            @httpServer.listen @port, =>
                console.log "http://... ready on port #{@port}"
                console.log "CraftingGuide is ready.\n\n"
                resolve this

    stop: ->
        w.promise (resolve, reject)=>
            console.log "CraftingGuide is shutting down"
            @httpServer.close() =>
                resolve this
