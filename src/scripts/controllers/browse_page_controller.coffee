###
Crafting Guide - browse_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class BrowsePageController extends BaseController

    constructor: (options={})->
        options.templateName = 'browse_page'
        super options
