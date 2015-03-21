###
Crafting Guide - tutorial_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class TutorialController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'tutorial'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$icon  = @$('img')
        @$link  = @$('a')
        @$title = @$('p')
        super

    refresh: ->
        templateData = modSlug:@model.modSlug, tutorialSlug:@model.slug
        @$icon.attr 'src', Url.tutorialIcon templateData
        @$link.attr 'href', Url.tutorial templateData
        @$title.html @model.name
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'
