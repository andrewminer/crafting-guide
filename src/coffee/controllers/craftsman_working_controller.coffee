###
Crafting Guide - crafting_grid_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
Craftsman      = require '../models/crafting/craftsman'
{Event}        = require '../constants'

########################################################################################################################

module.exports = class CraftsmanWorkingController extends BaseController

    constructor: (options={})->
        if not options.model then throw new Error 'options.model is required'
        options.templateName = 'craftsman_working'
        super options

        @model.on Event.change, => @_refreshStatusText()

    # BaseController Methods #######################################################################

    onDidRender: ->
        @$message = @$('.message p')
        @$count = @$('.count p')
        super

    refresh: ->
        @_refreshStatusText()
        super

    # Private Methods ##############################################################################

    _refreshStatusText: ->
        return unless @$message? and @$count?

        switch @model.stage
            when Craftsman::STAGE.WAITING
                @$message.html 'Preparing crafting calculation...'
                @$count.html ''
            when Craftsman::STAGE.GRAPHING
                @$message.html 'Researching recipes...'
                @$count.html "Found #{@model.stageCount} recipes so far..."
            when Craftsman::STAGE.PLANNING
                @$message.html 'Figuring out possible crafting plans...'
                @$count.html "Found #{@model.stageCount} possibilities so far..."
            when Craftsman::STAGE.ANALYZING
                @$message.html 'Looking for the best plan...'
                @$count.html "Finished checking #{@model.stageCount} so far..."
            when Craftsman::STAGE.COMPLETE
                @$message.html 'All done!'
                @$count.html ''
