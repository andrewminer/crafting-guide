#
# Crafting Guide - header_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController         = require '../base_controller'
ItemSelectorController = require '../common/item_selector/item_selector_controller'

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
        @router.navigate '/craft', trigger:true
        return false

    onBrowse: ->
        @router.navigate '/browse', trigger:true
        return false

    onLogin: ->
        if global.site.user?
            global.site.logout()
        else
            @router.navigate '/login', trigger:true
        return false

    onNews: ->
        @router.navigate '/news', trigger:true
        return false

    onSearch: ->
        @_selector.launch()
            .then (itemSlug)=>
                itemDisplay = @_modPack.findItemDisplay itemSlug
                @router.navigate itemDisplay.itemUrl, trigger:true
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
        @$loginButtonLabel = @$('.button.login p')
        @$title            = $('title')
        super

    onWillChangeModel: (oldModel, newModel)->
        if oldModel? then @stopListening oldModel.controller
        @listenTo newModel.controller, c.event.change, => @tryRefresh()
        return newModel

    refresh: ->
        @$loginButtonLabel.text if global.site.user? then "Logout" else "Login"

        @_refreshBreadcrumbs()
        @_refreshTitle()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        _.extend super,
            'click .craft':         'onCraft'
            'click .browse':        'onBrowse'
            'click .login':         'onLogin'
            'click .news':          'onNews'
            'click .search':        'onSearch'
            'click .breadcrumbs a': 'routeLinkClick'

    # Private Methods ##############################################################################

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

    _refreshTitle: ->
        title = @model?.controller?.getTitle()
        if title
            @$title.text c.text.titleWithText text: title
        else
            @$title.text c.text.title()
