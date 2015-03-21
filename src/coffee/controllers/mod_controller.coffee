###
Crafting Guide - mod_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class ModController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'mod'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$link        = @$('a')
        @$logo        = @$('.logo')
        @$name        = @$('.name p')
        @$description = @$('.description p')
        super

    refresh: ->
        @$link.attr 'href', Url.mod modSlug:@model.slug
        @$logo.attr 'src', Url.modIcon modSlug:@model.slug
        @$name.html @model.name
        @$description.html @model.description

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a': 'routeLinkClick'
