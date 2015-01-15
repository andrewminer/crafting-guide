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
        @_page             = null
        @_pageControllers  = {}
        @_lastReportedHref = null
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
        href = window.location.href
        return if @_lastReportedHref is href
        @_lastReportedHref = href

        if global.env is 'production'
            logger.info "Recording GA page view: #{href}"
            ga 'send', 'pageview', href
        else
            logger.info "Suppressing GA page view: #{href}"

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
