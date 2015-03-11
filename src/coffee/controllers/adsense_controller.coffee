###
Crafting Guide - adsense_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{AdsenseEnvs}  = require '../constants'

########################################################################################################################

module.exports = class AdsenseController extends BaseController

    constructor: (options={})->
        options.model ?= 'skyscraper_sidebar'
        options.templateName = "adsense_#{options.model}"
        super options

        @_adsEnabled = global.env in AdsenseEnvs

    # BaseController Overrides #####################################################################

    render: ->
        if @_adsEnabled
            super
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
