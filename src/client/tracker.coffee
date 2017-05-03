#
# Crafting Guide - tracker.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

w = require "when"

########################################################################################################################

module.exports = class Tracker

    @::TIMEOUT = 5000

    constructor: ->
        @_enabled = false

    # Public Methods ###############################################################################

    trackEvent: (category, action, label='', value=0)->
        return unless category?
        @_trackEvent category, action, label, value

    trackOutboundEvent: (category, action, label='', value=0)->
        return unless category?
        @_trackEvent category, action, label, value

    trackPageView: (pathname)->
        promise = w.promise (resolve, reject)=>
            pathname ?= window.location.pathname
            if @_enabled and ga?
                logger.info -> "Recording GA page view: #{pathname}"
                ga 'send', 'pageview', pathname, hitCallback: -> resolve true
            else
                logger.info -> "Suppressing GA page view: #{pathname}"
                resolve true

        promise.timeout @TIMEOUT
            .catch (error)->
                logger.error "Failed to send GA event!"

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        enabled:
            get: -> return @_enabled

            set: (newEnabled)->
                @_enabled = !! newEnabled

    # Private Methods ##############################################################################

    _trackEvent: (category, action, label='', value=0, options={})->
        promise = w.promise (resolve, reject)=>
            options.hitCallback = ->
                resolve true

            if @_enabled and ga?
                logger.info -> "Recording GA event: #{category}, #{action}, '#{label}', #{value}"
                ga 'send', 'event', category, action, label, value
            else
                logger.info -> "Suppressing GA event: #{category}, #{action}, '#{label}', #{value}"
                resolve true

        promise.timeout @TIMEOUT
            .catch (error)->
                logger.error -> "Failed to send GA event!: #{error}"
