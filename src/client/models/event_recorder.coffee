###
# Crafting Guide - event_recorder.coffee
#
# Copyright (c) 2014-2015 by Redwood Labs
# All rights reserved.
###

util = require 'util'

########################################################################################################################

module.exports = class EventRecorder

    constructor: (model)->
        if not model? then throw new Error 'model is required'

        @model = model
        @events = []

        @model.on 'all', (event, model, args...)=>
            logger.verbose -> "#{model?.constructor?.name}(#{model?.cid}) emitted #{event}
                with args: #{util.inspect(args)}"
            @events.push id:model?.cid, event:event, args:args

    # Public Methods ###############################################################################

    reset: ->
        @events = []

    # Property Methods #############################################################################

    getNames: ->
        return (e.event for e in @events)

    Object.defineProperties @prototype,
        names: {get:@prototype.getNames}
