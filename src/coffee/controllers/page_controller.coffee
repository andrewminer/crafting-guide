###
Crafting Guide - page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Text}         = require '../constants'

########################################################################################################################

module.exports = class PageController extends BaseController

    constructor: (options={})->
        super options

    # Public Methods ###############################################################################

    getTitle: ->
        # subclasses should override this to return the page-specific portion of the title
        return null

    # BaseController Overrides #####################################################################

    refresh: ->
        title = @getTitle()
        title = if title? then title.trim() else ''

        if title.length > 0
            title += " | #{Text.title}"
        else
            title = Text.title

        $('title').html title

        super