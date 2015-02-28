###
Crafting Guide - configure_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class ConfigurePageController extends BaseController

    constructor: (options={})->
        options.templateName = 'configure_page'
        super options
