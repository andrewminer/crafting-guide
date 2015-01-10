###
Crafting Guide - mod_pack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController       = require './base_controller'
{DefaultBookUrls}    = require '../constants'
ModVersionController = require './mod_version_controller'

########################################################################################################################

module.exports = class ModPackController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error "options.model is required"
        @_modVersionControllers = []

        options.templateName = 'mod_pack'
        super options

    # BaseController Overrides #####################################################################

    onWillRender: ->
        if @model.modVersions.length is 0
            @model.loadAllModVersions DefaultBookUrls

    onDidRender: ->
        @$table = @$('table')
        super

    refresh: ->
        @$('table tr').remove()
        return unless @model?

        @_modVersionControllers = []
        for i in [@model.modVersions.length-1..0] by -1
            modVersion = @model.modVersions[i]
            controller = new ModVersionController model:modVersion
            controller.render()
            @_modVersionControllers.push controller
            @$table.prepend controller.$el

        super
