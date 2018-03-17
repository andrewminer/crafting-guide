#
# Crafting Guide - server.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

require('dotenv').config()

########################################################################################################################

CraftingGuideServer = require './crafting_guide_server'
server = new CraftingGuideServer process.env.WEBSITE_SERVER_PORT
server.start()

process.on 'SIGINT', ->
    server.stop().finally ->
        process.exit()
