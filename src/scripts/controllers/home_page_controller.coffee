###
Crafting Guide - home_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class HomeController extends BaseController

    constructor: (options={})->
        options.templateName = 'home_page'
        super options

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .mainBody a': 'routeLinkClick'
