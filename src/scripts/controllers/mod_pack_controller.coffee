###
Crafting Guide - mod_pack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController       = require './base_controller'
{DefaultModVersions} = require '../constants'
{Duration}           = require '../constants'
ModVersion           = require '../models/mod_version'
ModVersionController = require './mod_version_controller'

########################################################################################################################

module.exports = class ModPackController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error "options.model is required"
        options.templateName = 'mod_pack'
        super options

        @_controllers = []

    # Event Methods ################################################################################

    onSuggestModClicked: ->
        return unless global.feedbackController?
        global.feedbackController.enterFeedback 'Please add mod:\n\n'

    # BaseController Overrides #####################################################################

    onWillRender: ->
        for attributes in DefaultModVersions
            modVersion = new ModVersion _.extend attributes, modPack:@model
            modVersion.fetch()

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
        while index < Math.min @_controllers.length, @model.modVersions.length
            controller = @_controllers[index]
            controller.model = @model.modVersions[index]
            index++

        while @_controllers.length < @model.modVersions.length
            controller = new ModVersionController model:@model.modVersions[index]
            controller.render()
            @_controllers.push controller
            controller.$el.hide duration:0
            @$table.append controller.$el
            controller.$el.slideDown duration:Duration.normal
            index++

        while @_controllers.length > @model.modVersions.length
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
