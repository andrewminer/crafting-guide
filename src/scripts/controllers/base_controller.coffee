###
Crafting Guide - base_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

views = require '../views'

########################################################################################################################

module.exports = class BaseController extends Backbone.View

    constructor: (options={})->
        Object.defineProperty this, 'model', get:@getModel, set:@setModel

        @_model    = null
        @_rendered = false
        @_parent   = options.parent
        @_children = []

        Object.defineProperty this, 'rendered', get:-> return @_rendered
        @_loadTemplate options.templateName
        super options

        @_tryRefresh = _.debounce @_tryRefresh, 100

    # Public Methods ###############################################################################

    addChild: (Controller, atSelector, options={})->
        options.el = @$(atSelector)[0]
        options.parent = this

        child = new Controller options
        child.render()
        @_children.push child
        return child

    refresh: ->
        logger.verbose "#{this} refreshing"

    # Event Methods ################################################################################

    onDidModelChange: ->
        @_tryRefresh()

    onDidModelSync: ->
        @_tryRefresh()

    onWillRender: -> # do nothing

    onDidRender: ->
        @_tryRefresh()

    onWillShow: -> # do nothing

    onDidShow: -> # do nothing

    onWillChangeModel: (oldModel, newModel)->
        if oldModel?.on?
            @stopListening oldModel
        if newModel?.on?
            @listenTo newModel, 'sync', (e)=> @onDidModelSync e
            @listenTo newModel, 'change', (e)=> @onDidModelChange e
        return true

    # Property Methods #############################################################################

    getModel: ->
        return @_model

    setModel: (newModel)->
        return if @model is newModel
        return unless @onWillChangeModel @_model, newModel

        @_model = newModel
        @_tryRefresh()

    # Backbone.View Overrides ######################################################################

    render: (options={})->
        return this unless not @_rendered or options.force

        data = (@model?.toHash? and @model.toHash()) or @model or {}

        if not @_template?
            logger.error "Default render called for #{@constructor.name} without a template"
            return this

        logger.verbose "#{this} rendering with data: #{data}"
        @onWillRender()
        $oldEl = @$el
        $newEl = Backbone.$(@_template(data))
        if $oldEl
            $oldEl.replaceWith $newEl
            $newEl.addClass $oldEl.attr 'class'

        @setElement $newEl
        @_rendered = true
        @onDidRender()

        return this

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name}(#{@cid})"

    # Private Methods ##############################################################################

    _loadTemplate: (templateName)->
        if templateName?
            @_template = views[templateName]

    _tryRefresh: ->
        return unless @_rendered
        @refresh()
