#
# Crafting Guide - page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require './base_controller'

########################################################################################################################

module.exports = class PageController extends BaseController

    constructor: (options={})->
        super options

    # Public Methods ###############################################################################

    getBreadcrumbs: ->
        return []

    getMetaDescription: ->
        # subclasses should override this to return the page-specific text for the meta description tag
        return null

    getTitle: ->
        # subclasses should override this to return the page-specific portion of the title
        return null

    # BaseController Overrides #####################################################################

    refresh: ->
        @_refreshMetaDescription()
        @_refreshTitle()
        super

    # Private Methods ##############################################################################

    _refreshMetaDescription: ->
        description = @getMetaDescription()
        description ?= ''

        if description.length > 0
            $('meta[name="description"]').remove()
            $('head').append "<meta name=\"description\" content=\"#{description}\">"

    _refreshTitle: ->
        title = @getTitle()
        title = if title? then title.trim() else ''

        if title.length > 0
            $('title').html c.text.titleWithText text:title
        else
            $('title').html c.text.title()
