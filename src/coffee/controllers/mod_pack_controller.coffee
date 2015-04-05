###
Crafting Guide - mod_pack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController        = require './base_controller'
ModSelectorController = require './mod_selector_controller'
{Duration}            = require '../constants'

########################################################################################################################

module.exports = class ModPackController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName  = 'mod_pack'
        super options

        @storage = options.storage

    # Event Methods ################################################################################

    onSuggestModClicked: ->
        return unless global.feedbackController?
        global.feedbackController.enterFeedback 'Please add mod:\n\n'

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$mods    = @$('.mods')
        @$toolbar = @$('.toolbar')
        super

    refresh: ->
        if global.feedbackController?
            @$toolbar.show duration:0
        else
            @$toolbar.hide duration:0

        @_refreshMods()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click button[name="suggestMod"]': 'onSuggestModClicked'

    # Private Methods ##############################################################################

    _refreshMods: ->
        @_modControllers ?= []
        index = 0

        if @model?
            @model.eachMod (mod)=>
                controller = @_modControllers[index]
                if not controller?
                    controller = new ModSelectorController model:mod, storage:@storage
                    controller.render()
                    @$mods.append controller.$el
                    @_modControllers.push controller
                else
                    controller.model = mod

                index += 1

        while @_modControllers.length > index
            @_modControllers.pop().remove()
