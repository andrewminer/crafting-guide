#
# Crafting Guide - news_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

AdsenseController = require '../common/adsense/adsense_controller'
PageController    = require '../page_controller'

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

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_adsenseController = @addChild AdsenseController, '.view__adsense', model:'skyscraper'

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            'click a': 'routeLinkClick'
