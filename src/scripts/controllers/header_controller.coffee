###
Crafting Guide - header_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class HeaderController extends BaseController

    constructor: (options={})->
        super options

    # Event Methods ################################################################################

    onLogoClicked: ->
        router.navigate '/', trigger:true
        return false

    # BaseController Overrides #####################################################################

    render: ->
        # Overriding render because the header is already part of the stock page layout, and we
        # don't need to replace it here.

    # Backbone.View Overrides ######################################################################

    events:
        'click a.logo': 'onLogoClicked'
