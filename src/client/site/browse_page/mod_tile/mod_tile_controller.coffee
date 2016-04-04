#
# Crafting Guide - mod_tile_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'

########################################################################################################################

module.exports = class ModTileController extends BaseController

    constructor: (options={})->
        options.templateName = 'browse_page/mod_tile'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$link        = @$('a')
        @$logoImage   = @$('img')
        @$title       = @$('p.title')
        @$description = @$('p.description')
        super

    refresh: ->
        @$link.attr 'href', c.url.mod modSlug:@model.slug
        @$logoImage.attr 'src', c.url.modIcon modSlug:@model.slug
        @$title.text @model.name
        @$description.text @model.description

        if @model.enabled
            @$el.removeClass 'disabled'
        else
            @$el.addClass 'disabled'

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            'click a': 'routeLinkClick'
