###
Crafting Guide - page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

$              = require 'jquery'
BaseController = require './base_controller'
{Text}         = require '../constants'

########################################################################################################################

module.exports = class PageController extends BaseController

    constructor: (options={})->
        super options

    # Public Methods ###############################################################################

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
            $('title').html Text.titleWithText text:title
        else
            $('title').html Text.title()
