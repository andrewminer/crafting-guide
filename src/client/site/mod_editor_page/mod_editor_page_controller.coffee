#
# Crafting Guide - mod_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

PageController      = require '../page_controller'

########################################################################################################################

module.exports = class ModPageController extends PageController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'mod_editor_page'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack

    # Event Methods ################################################################################

    # Property Methods #############################################################################

    # PageController Overrides #####################################################################

    getBreadcrumbs: ->

    getTitle: ->

    # BaseController Overrides #####################################################################

    onDidRender: ->
        super

    refresh: ->
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,

    # Private Methods ##############################################################################
