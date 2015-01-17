###
Crafting Guide - base_model.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

{Event}      = require '../constants'
{ModelState} = require '../constants'

########################################################################################################################

module.exports = class BaseModel extends Backbone.Model

    constructor: (attributes={}, options={})->
        options.silent ?= true
        super attributes, options

        makeGetter = (name)-> return -> @get name
        makeSetter = (name)-> return (value)-> @set name, value
        for name, value of attributes
            continue if name is 'id'
            Object.defineProperty this, name, get:makeGetter(name), set:makeSetter(name)

        @silent = options.silent
        @state  = ModelState.unloaded

        @on 'request', => @state = ModelState.loading
        @on 'sync',    => @state = ModelState.loaded
        @on 'error',   => @state = ModelState.error

        @loading = null

    # Public Methods ###############################################################################

    # Event Methods ################################################################################

    onLoadSucceeded: (text, status, xhr)->
        try
            @set @parse text
            @trigger Event.sync, this, text
        catch e
            logger.error "A parsing error occured: #{e.stack}"
            @onLoadFailed e.message, 'parsing failed', xhr

    onLoadFailed: (error, status, xhr)->
        logger.error "#{@constructor.name} (#{@cid}) failed to load: status:#{status}, message:#{error}"
        @trigger Event.error, this, error

    # Backbone.Model Overrides #####################################################################

    fetch: ->
        url = @url()
        logger.info "#{@constructor.name} (#{@cid}) reading from url: #{url}"

        @trigger Event.request, this
        @loading = w.promise (resolve, reject)=>
            $.ajax
                url:      url
                dataType: 'text'
                success:  (text, status, xhr)=> resolve @onLoadSucceeded text, status, xhr
                error:    (xhr, status, error)=> reject @onLoadFailed error, status, xhr

        @loading.catch -> # do nothing. prevents unhandled promise warnings
        return @loading

    parse: (text)->
        return JSON.parse text

    sync: (method, model)->
        throw new Error "#{@constructor.name} (#{@cid}) is not permitted to #{method}"

    trigger: (name)->
        return if @silent
        logger.trace "#{@constructor.name}.#{@cid} triggered a \"#{name}\" event"
        super

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid})"
