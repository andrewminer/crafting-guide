#
# Crafting Guide - header_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController         = require '../base_controller'
ItemDisplay            = require "../../models/site/item_display"
ItemSelectorController = require '../common/item_selector/item_selector_controller'
UrlParams              = require '../url_params'

########################################################################################################################

module.exports = class HeaderController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.model        ?= {}
        options.templateName  = 'header'
        super options

        @_modPack = options.modPack

        global.site.on c.event.change + ':user', => @tryRefresh()

    # Event Methods ################################################################################

    onCraft: ->
        tracker.trackEvent c.tracking.category.navigate, 'click-button', 'craft'
        @router.navigate '/craft', trigger:true
        return false

    onBrowse: ->
        tracker.trackEvent c.tracking.category.navigate, 'click-button', 'browse'
        @router.navigate '/browse', trigger:true
        return false

    onLogin: ->
        if global.site.user?
            tracker.trackEvent c.tracking.category.account, 'logout'
            global.site.logout()
        else
            tracker.trackEvent c.tracking.category.navigate, 'click-button', 'login'
            @router.navigate '/login', trigger:true
        return false

    onNews: ->
        tracker.trackEvent c.tracking.category.navigate, 'click-button', 'news'
        @router.navigate '/news', trigger:true
        return false

    onSearch: (event, hint='')->
        tracker.trackEvent c.tracking.category.search, 'launch'
        @_selector.launch hint
            .then (item)=>
                if not item?
                    tracker.trackEvent c.tracking.category.search, 'cancel'
                    return

                tracker.trackEvent c.tracking.category.search, 'complete', item.slug
                itemDisplay = new ItemDisplay item
                @router.navigate itemDisplay.url, trigger:true
        return false

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_selector = @addChild ItemSelectorController, null, modPack: @_modPack

        if global.env in c.productionEnvs
            addThisUrl = 'http://s7.addthis.com/js/300/addthis_widget.js?pubid=ra-54f3c9717b2e530d'
            $('body').append "<script async=\"async\" src=\"#{addThisUrl}\"></script>"
        else
            @$('.addthis_sharing_toolbox').addClass 'placeholder'

        @$breadcrumbs      = @$('.breadcrumbs')
        @$extraNav         = @$('.extra-nav')
        @$loginButtonLabel = @$('.button.login p')
        @$title            = $('title')

        @_checkForSearchRequest()
        super

    onWillChangeModel: (oldModel, newModel)->
        if oldModel? then @stopListening oldModel.controller
        @listenTo newModel.controller, c.event.change, => @tryRefresh()
        return newModel

    refresh: ->
        @$loginButtonLabel.text if global.site.user? then "Logout" else "Login"

        @_refreshBreadcrumbs()
        @_refreshExtraNav()
        @_refreshSelectedNavButton()
        @_refreshTitle()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            'click .craft':            'onCraft'
            'click .browse':           'onBrowse'
            'click .login':            'onLogin'
            'click .news':             'onNews'
            'click .search':           'onSearch'
            'click .breadcrumb-bar a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _checkForSearchRequest: ->
        params = new UrlParams search:{type:'string'}
        return unless params.search?

        _.delay (=> @onSearch {}, params.search), c.duration.slow

    _refreshBreadcrumbs: ->
        breadcrumbs = @model?.controller?.getBreadcrumbs()
        breadcrumbs ?= []

        if breadcrumbs.length > 0
            @$breadcrumbs.empty()

            for crumb, index in breadcrumbs
                if index isnt 0 then @$breadcrumbs.append $("<span>⟩</span>")
                @$breadcrumbs.append crumb

            @show @$breadcrumbs
        else
            @hide @$breadcrumbs

    _refreshExtraNav: ->
        return unless _.isFunction @model?.controller?.getExtraNav
        extraNavContent = @model.controller.getExtraNav()

        if extraNavContent?
            @$extraNav.empty()
            @$extraNav.append extraNavContent
            @show @$extraNav
        else
            @hide @$extraNav


    _refreshSelectedNavButton: ->
        return unless @model?.page?

        @$('.button').removeClass 'active'
        @$(".button.#{@model.page}").addClass 'active'

    _refreshTitle: ->
        title = @model?.controller?.getTitle()
        if title
            @$title.text c.text.titleWithText text: title
        else
            @$title.text c.text.title()
