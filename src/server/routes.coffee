#
# Crafting Guide - routes.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express = require 'express'

############################################################################################################

module.exports = router = express.Router()

sendIndex = (request, response)->
    response.sendFile 'index.html', root: 'static'

router.get '/browse*', sendIndex
router.get '/craft*', sendIndex
router.get '/login*', sendIndex
router.get '/news*', sendIndex
