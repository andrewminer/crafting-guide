#
# Crafting Guide - base_model.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

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

        @fileCache = options.fileCache or null
        @loading   = null
        @logEvents = options.logEvents or false
        @state     = c.modelState.unloaded

        Object.defineProperties this,
            isUnloaded: { get:-> @state is c.modelState.unloaded }
            isLoading:  { get:-> @state is c.modelState.loading  }
            isLoaded:   { get:-> @state is c.modelState.loaded   }
            isError:    { get:-> @state is c.modelState.error    }

    # Event Methods ################################################################################

    onLoadSucceeded: (text, status, xhr)->
        try
            @set @parse text

            @state = c.modelState.loaded
            @trigger c.event.change, this
            @trigger c.event.sync, this
            logger.info => "#{@constructor.name}.#{@cid} loaded successfully"
        catch e
            logger.error -> "A parsing error occured: #{e.stack}"
            @onLoadFailed e.message, 'parsing failed', xhr

    onLoadFailed: (error, status, xhr)->
        @state = c.modelState.error
        logger.error => "#{@constructor.name}.#{@cid} failed to load: status:#{status}, message:#{error}"
        @trigger c.event.error, this, error

    # Backbone.Model Overrides #####################################################################

    fetch: (options={})->
        options.force ?= false
        return if (@isLoading or @isLoaded) and not options.force

        url = @url()
        logger.info => "#{@constructor.name}.#{@cid} reading from url: #{url}"

        @state = c.modelState.loading
        @trigger c.event.request, this

        loadFromServer = =>
            w.promise (resolve, reject)=>
                $.ajax
                    url:      url
                    dataType: 'text'
                    success:  (text, status, xhr)=> resolve @onLoadSucceeded text, status, xhr
                    error:    (xhr, status, error)=> reject @onLoadFailed error, status, xhr

        if @fileCache?
            @loading = @fileCache.loading.then =>
                if @fileCache.hasFile url
                    @onLoadSucceeded @fileCache.getFile(url), 'success', {url:url}
                    return w.resolve(true)
                else
                    @loading = loadFromServer()
        else
            @loading = loadFromServer()

        @loading.catch (e)-> # do nothing
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
