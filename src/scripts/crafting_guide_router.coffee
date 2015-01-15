###
Crafting Guide - router.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

{Duration}         = require './constants'
{Event}            = require './constants'
ItemPageController = require './controllers/item_page_controller'
{Opacity}          = require './constants'
UrlParams          = require './url_params'

########################################################################################################################

module.exports = class CraftingGuideRouter extends Backbone.Router

    constructor: (options={})->
        @_page            = null
        @_pageControllers = {}
        @_lastReported    = null
        super options

    # Backbone.Router Overrides ####################################################################

    navigate: ->
        super
        @_recordPageView()

    routes:
        '':             'root'
        'item(/:name)': 'item'

    # Route Methods ################################################################################

    root: ->
        params = new UrlParams recipeName:{type:'string'}, count:{type:'integer'}
        @item params.recipeName, params.count

    item: (name, quantity=1)->
        @_pageControllers.item ?= new ItemPageController
        @_pageControllers.item.model.params = name:name, quantity:quantity
        @_setPage 'item'

    # Private Methods ##############################################################################

    _recordPageView: ->
        pathname = window.location.pathname
        return if @_lastReported is pathname
        @_lastReported = pathname

        if global.env is 'production'
            logger.info "Recording GA page view: #{pathname}"
            ga 'send', 'pageview', pathname
        else
            logger.info "Suppressing GA page view: #{pathname}"

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
            controller.$el.addClass 'page'
            $pageContent.replaceWith controller.$el

            controller.$el.fadeIn showDuration, ->
                controller.onDidShow()

        if @_mainController?
            showDuration = Duration.fast
            @_page.$el.fadeOut Duration.fast, show
        else
            show()
