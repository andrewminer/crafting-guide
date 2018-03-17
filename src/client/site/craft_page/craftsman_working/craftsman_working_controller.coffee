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

    @::HIDE_TIMER_DURATION = 2000

    constructor: (options={})->
        if not options.model then throw new Error 'options.model is required'
        options.templateName = 'craft_page/craftsman_working'
        super options

        @_hideTimer = null

    # Event Methods ################################################################################

    onButtonClicked: ->
        @trigger c.event.click
        @model.reset()
        @model.work()
        return false

    # BaseController Methods #######################################################################

    onDidModelChange: ->
        @refresh()

    onDidRender: ->
        @$button   = @$('.button')
        @$count    = @$('.count p')
        @$message  = @$('.message p')
        @$outdated = @$('.outdated')
        @$waiting  = @$('.waiting')

        @_controls = [@$button, @$count, @$message, @$outdated, @$waiting]
        super

    refresh: ->
        return unless @$message? and @$count?

        button = count = message = outdated = waiting = null

        switch @model.stage
            when Craftsman::STAGE.READY
                message = 'Ready to compute crafting plan!'
                count = 'Click "Calculate" to continue.'
                button = true
            when Craftsman::STAGE.GRAPHING
                message = 'Researching recipes...'
                count = "Found #{@model.stageCount} recipes so far..."
                watiing = true
            when Craftsman::STAGE.PLANNING
                message = 'Figuring out possible crafting plans...'
                count = "Found #{@model.stageCount} possibilities so far..."
                watiing = true
            when Craftsman::STAGE.ANALYZING
                message = 'Looking for the best plan...'
                count = "Finished checking #{@model.stageCount} so far..."
                watiing = true
            when Craftsman::STAGE.COMPLETE
                message = 'Crafting plan is complete.'
            when Craftsman::STAGE.INVALID
                message = 'Couldn\'t make a crafting plan!'
                count = 'Please report this problem using the Feedback box.'
            when Craftsman::STAGE.OUTDATED
                message = 'Your crafting plan is out of date!'
                count = 'Click "Calculate" to re-compute.'
                button = true
                outdated = true

        @hide(control) for control in @_controls

        if button?
            @show @$button

        if count?
            @show @$count
            @$count.html count

        if message?
            @show @$message
            @$message.html message

        if outdated?
            @show @$outdated

        if waiting?
            @show @$waiting

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .button': 'onButtonClicked'
