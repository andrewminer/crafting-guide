###
Crafting Guide - whats_new_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class WhatsNewController extends BaseController

    constructor: (options={})->
        options.templateName = 'whats_new_page'
        super options
