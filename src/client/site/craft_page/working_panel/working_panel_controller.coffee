#
# Crafting Guide - working_panel_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'
CraftPage      = require "../../../models/site/craft_page"

########################################################################################################################

module.exports = class WorkingPanelController extends BaseController

    @::HIDE_TIMER_DURATION = 2000

    constructor: (options={})->
        if not options.model?.constructor is CraftPage then throw new Error "options.model must be a CraftPage"
        options.templateName = "craft_page/working_panel"
        super options

        @_hideTimer = null

    # Event Methods ################################################################################

    onButtonClicked: ->
        tracker.trackEvent c.tracking.category.craft, "start"
        @trigger c.event.click
        @model.createPlan()
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

        button = count = message = outdated = null

        if @model.isOutdated
            message = "Your crafting plan is out of date!"
            count = 'Click "Calculate" to re-compute.'
            button = true
            outdated = true
        else if @model.currentPlan?
            message = "Crafting plan is complete."
        else
            message = "Ready to compute crafting plan!"
            count = 'Click "Calculate" to continue.'
            button = true

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
