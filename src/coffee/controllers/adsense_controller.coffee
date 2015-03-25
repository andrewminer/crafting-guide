###
Crafting Guide - adsense_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController   = require './base_controller'
{Adsense}        = require '../constants'
{ProductionEnvs} = require '../constants'

########################################################################################################################

module.exports = class AdsenseController extends BaseController

    constructor: (options={})->
        options.model        ?= 'skyscraper_sidebar'
        options.tagName       = 'ins'
        options.templateName  = "adsense_#{options.model}"
        super options

        @_adsEnabled = global.env in ProductionEnvs

    # BaseController Overrides #####################################################################

    render: ->
        if @_adsEnabled
            super

            @$el.attr 'data-ad-client', Adsense.clientId
            @$el.attr 'data-ad-slot', Adsense.slotId
        else
            @$el.addClass 'placeholder'
            @_rendered = true

        @$el.addClass @model

    refresh: ->
        return unless @_adsEnabled

        try
            global.adsbygoogle ||= []
            global.adsbygoogle.push {}
        catch e
            logger.warning "Could not load Adsense ad: #{e}"
