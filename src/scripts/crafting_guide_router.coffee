###
Crafting Guide - router.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

{Duration}         = require './constants'
ItemPageController = require './controllers/item_page_controller'
{Opacity}          = require './constants'
UrlParams          = require './url_params'

########################################################################################################################

module.exports = class CraftingGuideRouter extends Backbone.Router

    constructor: (options={})->
        @_page = null
        @_pageControllers = {}
        super options

    # Backbone.Router Overrides ####################################################################

    routes:
        '':             'root'
        'item(/:name)': 'item'

    # Route Methods ################################################################################

    root: ->
        params = new UrlParams
            recipeName:     {type:'string'}
            count:          {type:'integer'}

        if params.recipeName?
            @navigate "/item/#{encodeURIComponent(params.recipeName)}"

        @item params.recipeName, params.count

    item: (name, quantity=1)->
        @_pageControllers.item ?= new ItemPageController
        @_pageControllers.item.setParams name:name, quantity:quantity
        @_setPage 'item'

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
            controller.$el.addClass 'page'
            $pageContent.replaceWith controller.$el

            controller.$el.fadeIn showDuration, ->
                controller.onDidShow()

        if @_mainController?
            showDuration = Duration.fast
            @_page.$el.fadeOut Duration.fast, show
        else
            show()
