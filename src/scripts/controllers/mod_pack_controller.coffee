###
Crafting Guide - mod_pack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{DefaultMods}  = require '../constants'
{Duration}     = require '../constants'
Mod            = require '../models/mod'
ModController  = require './mod_controller'

########################################################################################################################

module.exports = class ModPackController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.plan? then throw new Error 'options.plan is required'
        options.templateName  = 'mod_pack'
        super options

        @_controllers = []
        @_plan        = options.plan
        @_storage     = options.storage

    # Event Methods ################################################################################

    onSuggestModClicked: ->
        return unless global.feedbackController?
        global.feedbackController.enterFeedback 'Please add mod:\n\n'

    # BaseController Overrides #####################################################################

    onWillRender: ->
        for name in DefaultMods
            @model.addMod new Mod name:name

    onDidRender: ->
        @$table = @$('table')
        @$toolbar = @$('.toolbar')
        super

    refresh: ->
        if not @model?
            @_controllers = []
            @$('table tr').remove()
            return

        index = 0
        mods = @model.getMods()
        while index < Math.min @_controllers.length, mods.length
            controller = @_controllers[index]
            controller.model = mods[index]
            index++

        while @_controllers.length < mods.length
            controller = new ModController model:mods[index], plan:@_plan, storage:@_storage
            controller.render()
            @_controllers.push controller
            controller.$el.hide duration:0
            @$table.append controller.$el
            controller.$el.slideDown duration:Duration.normal
            index++

        while @_controllers.length > mods.length
            controller = @_controllers.pop()
            controller.$el.slideUp duration:Duration.normal, complete:-> controller.$el.remove()

        if global.feedbackController?
            @$toolbar.show duration:0
        else
            @$toolbar.hide duration:0

        super

    # Backbone.View Overrides ######################################################################

    events:
        'click button[name="suggestMod"]': 'onSuggestModClicked'
