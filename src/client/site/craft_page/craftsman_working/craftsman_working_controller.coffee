#
# Crafting Guide - craftsman_working_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'
Craftsman      = require '../../../models/crafting/craftsman'

########################################################################################################################

module.exports = class CraftsmanWorkingController extends BaseController

    constructor: (options={})->
        if not options.model then throw new Error 'options.model is required'
        options.templateName = 'craft_page/craftsman_working'
        super options

        @model.on c.event.change, => @_refreshStatusText()

    # BaseController Methods #######################################################################

    onDidRender: ->
        @$message = @$('.message p')
        @$count = @$('.count p')
        @$waiting = @$('.waiting')
        super

    refresh: ->
        @_refreshStatusText()
        super

    # Private Methods ##############################################################################

    _refreshStatusText: ->
        return unless @$message? and @$count?

        @show @$waiting
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
            when Craftsman::STAGE.INVALID
                @$message.html 'Couldn\'t make a crafting plan'
                @$count.html ''
                @hide @waiting
