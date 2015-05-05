###
Crafting Guide - base_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

$          = require 'jquery'
_          = require 'underscore'
backbone   = require 'backbone'
views      = require '../views'
{Duration} = require '../constants'
{Event}    = require '../constants'

########################################################################################################################

module.exports = class BaseController extends backbone.View

    constructor: (options={})->
        @tryRefresh = _.debounce @_tryRefresh, 100

        @_children      = []
        @_model         = null
        @_parent        = options.parent
        @_rendered      = false
        @_useAnimations = options.useAnimations ?= true

        @_loadTemplate options.templateName
        super options

    # Public Methods ###############################################################################

    addChild: (Controller, atSelector, options={})->
        options.el = @$(atSelector)[0]
        options.parent = this

        child = new Controller options
        child.render options
        @_children.push child
        return child

    hide: ($el)->
        $el ?= @$el

        if not $el.hasClass 'hideable'
            $el.addClass 'hideable'
            _.defer => @hide $el
            return

        if not ($el.hasClass('hiding') or $el.hasClass('hidden'))
            logger.verbose => "#{this} is hiding \"#{$el.selector}\""
            @_onAnimationComplete $el, Duration.normal, =>
                $el.addClass 'hidden'
                $el.removeClass 'hiding'
                logger.verbose => "#{this} is finished hiding #{$el.selector}"
                @trigger Event.animate.hide.finish, this, $el

            $el.addClass 'hiding'
            @trigger Event.animate.hide.start, this, $el

    refresh: ->
        logger.verbose => "#{this} refreshing"

    remove: ->
        if @_useAnimations
            logger.verbose => "#{this} is hiding element before removing it"
            @once Event.animate.hide.finish, =>
                logger.verbose => "#{this} is removing its element from the DOM"
                @$el.remove()
                @off()
            @hide()
        else
            @$el.remove()
            @off()

    routeLinkClick: (event)->
        event.preventDefault()
        href = $(event.target).attr 'href'
        href ?= $(event.currentTarget).attr 'href'
        logger.info "Re-routing link to internal navigation: #{href}"

        if href? and href.match /^http/
            window.location.href = href
        else
            router.navigate href, trigger:true

    show: ($el)->
        $el ?= @$el
        $el.addClass 'hideable'

        if $el.hasClass('hidden') or $el.hasClass('hiding')
            logger.verbose => "#{this} is showing \"#{$el.selector}\""

            @_onAnimationComplete $el, Duration.normal, =>
                logger.verbose => "#{this} is finished showing #{$el.selector}"
                @trigger Event.animate.show.finish, this, $el

            $el.addClass 'hiding'
            $el.removeClass 'hidden'
            _.defer =>
                $el.removeClass 'hiding'
                @trigger Event.animate.show.start, this, $el

    unrender: ->
        @undelegateEvents()
        @$el.empty()

    # Event Methods ################################################################################

    onDidModelChange: ->
        @tryRefresh()

    onDidModelSync: ->
        @tryRefresh()

    onWillRender: -> # do nothing

    onDidRender: ->
        @tryRefresh()

    onWillShow: -> # do nothing

    onDidShow: -> # do nothing

    onWillChangeModel: (oldModel, newModel)->
        if oldModel?.on?
            @stopListening oldModel
        if newModel?.on?
            @listenTo newModel, 'sync', (e)=> @onDidModelSync e
            @listenTo newModel, 'change', (e)=> @onDidModelChange e
        return newModel

    # Property Methods #############################################################################

    getModel: ->
        return @_model

    setModel: (newModel)->
        return if @model is newModel

        newModel = @onWillChangeModel @_model, newModel
        @_model = newModel
        @tryRefresh()

    isRendered: ->
        return @_rendered

    getUser: ->
        return @_user

    setUser: (user)->
        @_user = user
        @tryRefresh()

    Object.defineProperties @prototype,
        model:    {get:@prototype.getModel, set:@prototype.setModel}
        rendered: {get:@prototype.isRendered }
        user:     {get:@prototype.getUser, set:@prototype.setUser}

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
        @$el.data $renderedEl.data()
        @delegateEvents()

        @_rendered = true
        @onDidRender()

        return this

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name}.#{@cid}"

    # Private Methods ##############################################################################

    _loadTemplate: (templateName)->
        if templateName?
            @_template = views[templateName]

    _tryRefresh: ->
        return unless @_rendered
        @refresh()

    _onAnimationComplete: ($el, maxDuration, callback)->
        $el         ?= @$el
        maxDuration ?= Duration.slow
        callback    ?= -> # do nothing

        $el.off Event.transitionEnd
        $el.one Event.transitionEnd, callback

        # One would very much like this not to be necessary, but because of the way CSS transitions work, they are
        # frequently not triggered. Rather than try to avoid the multitude of corner cases where this can happen, this
        # simply sets a timer to ensure the event does eventually trigger. Since we're only listening for the first
        # event, if the transition end event *did* happen, then this is a no-op. -- Andrew 2015-04-18
        setTimeout (-> $el.trigger Event.transitionEnd), maxDuration
