#
# Crafting Guide - news_page_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

PageController = require '../page_controller'

########################################################################################################################

module.exports = class NewsPageController extends PageController

    constructor: (options={})->
        options.templateName = 'news_page'
        super options

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return c.text.newsDescription()

    getTitle: ->
        return "News"

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            'click a': 'routeLinkClick'
