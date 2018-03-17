#
# Crafting Guide - base_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Observable} = require("crafting-guide-common").util
templates    = require './templates'

########################################################################################################################

module.exports = class BaseController extends Backbone.View

    constructor: (options={})->
        @_children = []
        @_model    = null
        @_parent   = options.parent
        @_rendered = false

        @router = options.router

        @tryRefresh = _.debounce (=> @_tryRefresh()), 100

        @_loadTemplate options.templateName
        super options

    # Public Methods ###############################################################################

    addChild: (Controller, atSelector, options={})->
        if not _.isFunction Controller then throw new Error "Controller must be a constructor"

        options.el = @$(atSelector)[0]
        options.parent = this

        child = new Controller options
        child.render options
        @_children.push child
        return child

    hide: ($el)->
        $el ?= @$el
        $el.css 'display', 'none'

    refresh: ->
        logger.verbose => "#{this} refreshing"

    remove: ->
        @$el.remove()
        @off()

    routeLinkClick: (event)->
        $link = $(event.target)
        if not $link.attr('href')?
            $link = $(event.currentTarget)

        href = $link.attr 'href'
        target = $link.attr 'target'

        logger.info -> "Re-routing link to internal navigation: #{href}"

        if href? and href.match /^http/
            tracker.trackEvent c.tracking.category.navigate, 'external-link', href
                .then -> window.location.href = href
            return false
        else if target?
            tracker.trackEvent c.tracking.category.navigate, 'external-link', href
            return true
        else
            tracker.trackEvent c.tracking.category.navigate, 'internal-link', href
            @router.navigate href, trigger:true
            return false

    show: ($el)->
        $el ?= @$el
        $el.css 'display', ''

    unrender: ->
        @undelegateEvents()
        @$el.empty()
        @_rendered = false

    # Event Methods ################################################################################

    onDidModelChange: ->
        @tryRefresh()

    onWillRender: -> # do nothing

    onDidRender: -> # do nothing

    onWillShow: -> # do nothing

    onDidShow: -> # do nothing

    onWillChangeModel: (oldModel, newModel)->
        if oldModel?.isObservable
            oldModel.off target:this

        if newModel?.isObservable
            newModel.on Observable::ANY, this, "onDidModelChange"

        return newModel

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        model:
            get: -> @_model
            set: (newModel)->
                return if @model is newModel

                newModel = @onWillChangeModel @_model, newModel
                @_model = newModel
                @onDidModelChange()

        rendered:
            get: -> @_rendered

        user:
            get: -> @_user
            set: (newUser)->
                @_user = newUser
                @tryRefresh()

    # Backbone.View Overrides ######################################################################

    events: ->
        return {}

    render: (options={})->
        options.force ?= false
        options.show ?= true
        return this unless not @_rendered or options.force

        if not @_template?
            logger.error => "Default render called for #{@constructor.name} without a template"
            return this

        data = (@model?.toHash? and @model.toHash()) or @model or {}
        logger.verbose => "#{this} rendering with data: #{data}"
        $renderedEl = $($(@_template(data))[0])

        @onWillRender()
        @unrender()

        @$el.append $renderedEl.children()
        @$el.addClass $renderedEl.attr 'class'

        elementData = $renderedEl.data()
        elementData.controller = this
        elementData.model = data
        @$el.data elementData

        @delegateEvents()
        @_rendered = true
        @onDidRender()

        @refresh()

        return this

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name}.#{@cid}"

    # Private Methods ##############################################################################

    _loadTemplate: (templateName)->
        if templateName?
            @_template = templates[templateName]

    _tryRefresh: ->
        return unless @_rendered
        @refresh()
