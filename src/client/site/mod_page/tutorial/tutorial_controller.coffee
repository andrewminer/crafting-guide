#
# Crafting Guide - tutorial_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'

########################################################################################################################

module.exports = class TutorialController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'mod_page/tutorial'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$icon  = @$('img')
        @$link  = @$('a')
        @$title = @$('p')
        super

    refresh: ->
        templateData = modSlug:@model.modSlug, tutorialSlug:@model.slug
        @$icon.attr 'src', c.url.tutorialIcon templateData
        @$link.attr 'href', c.url.tutorial templateData
        @$title.html @model.name
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'
