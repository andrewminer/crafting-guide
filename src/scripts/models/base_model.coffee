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
        options.logEvents ?= true
        super attributes, options

        makeGetter = (name)-> return -> @get name
        makeSetter = (name)-> return (value)-> @set name, value
        for name, value of attributes
            continue if name is 'id'
            Object.defineProperty this, name, get:makeGetter(name), set:makeSetter(name)

        @logEvents = options.logEvents or false
        @state  = ModelState.unloaded

        @loading = null

        Object.defineProperties this,
            isUnloaded: { get:-> @state is ModelState.unloaded }
            isLoading:  { get:-> @state is ModelState.loading  }
            isLoaded:   { get:-> @state is ModelState.loaded   }
            isError:    { get:-> @state is ModelState.error    }

    # Event Methods ################################################################################

    onLoadSucceeded: (text, status, xhr)->
        try
            @set @parse text

            @state = ModelState.loaded
            @trigger Event.change, this
            @trigger Event.sync, this
            logger.info => "#{@constructor.name}.#{@cid} loaded successfully"
        catch e
            logger.error -> "A parsing error occured: #{e.stack}"
            @onLoadFailed e.message, 'parsing failed', xhr

    onLoadFailed: (error, status, xhr)->
        @state = ModelState.error
        logger.error => "#{@constructor.name}.#{@cid} failed to load: status:#{status}, message:#{error}"
        @trigger Event.error, this, error

    # Backbone.Model Overrides #####################################################################

    fetch: (options={})->
        options.force ?= false
        return if (@isLoading or @isLoaded) and not options.force

        url = @url()
        logger.info => "#{@constructor.name}.#{@cid} reading from url: #{url}"

        @state = ModelState.loading
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
        throw new Error "#{@constructor.name}.#{@cid} is not permitted to #{method}"

    trigger: (name, model, args...)->
        if @logEvents
            argText = ("#{arg}"[0..50] for arg in args).join ", "
            logger.trace => "#{@constructor.name}.#{@cid} triggered event #{name} with args: #{argText}"
        super

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name}.#{@cid}"
