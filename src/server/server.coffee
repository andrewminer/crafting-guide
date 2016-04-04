#
# Crafting Guide - server.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingGuideServer = require './crafting_guide_server'

########################################################################################################################

global._ = require './underscore'
global.c = require './constants'
global.w = require 'when'

########################################################################################################################

port = parseInt process.argv[2]
port = if _.isNaN port then c.server.defaultPort else port

server = new CraftingGuideServer port
server.start()

process.on 'SIGINT', ->
    server.stop().finally ->
        process.exit()
