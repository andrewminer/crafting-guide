###
# Crafting Guide - router.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

{Duration}            = require './constants'
LandingPageController = require './controllers/landing_page_controller'
{Opacity}             = require './constants'

########################################################################################################################

module.exports = class CraftingGuideRouter extends Backbone.Router

    constructor: (options={})->
        @_page = null
        @_pageControllers = {}
        super options

    # Backbone.Router Overrides ####################################################################

    routes:
        '': 'landing'

    # Route Methods ################################################################################

    landing: ->
        @_pageControllers.landing ?= new LandingPageController
        @_setPage 'landing'

    # Private Methods ##############################################################################

    _setPage: (controllerName)->
        controller = @_pageControllers[controllerName]
        if not controller? then throw new Error "cannot find controller named: #{controllerName}"
        return if @_page is controller

        logger.info "changing to #{controllerName} page"
        showDuration = Duration.normal
        show = =>
            @_page = controller

            controller.onWillShow()
            controller.render()

            $pageContent = $('.page')
            $pageContent.empty()
            $pageContent.append controller.$el

            controller.$el.fadeIn showDuration, ->
                controller.onDidShow()

        if @_mainController?
            showDuration = Duration.fast
            @_page.$el.fadeOut Duration.fast, show
        else
            show()
