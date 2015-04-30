###
Crafting Guide - adsense_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

$                = require 'jquery'
BaseController   = require './base_controller'
_                = require 'underscore'
{Adsense}        = require '../constants'
{Duration}       = require '../constants'
{ProductionEnvs} = require '../constants'

########################################################################################################################

module.exports = class AdsenseController extends BaseController

    constructor: (options={})->
        options.templateName = "adsense_sidebar_skyscraper"
        super options

        @_adsEnabled  = global.env in ProductionEnvs
        @_adHeight    = 630
        @_adCount     = 0
        @_waiting     = false

    # Public Methods ###############################################################################

    fillAdPositions: ->
        if @_adCount > 0
            return unless @_adCount < Adsense.slotIds.length
            return unless @$sidebar? and @$mainBody?
            return unless @$sidebar.height() + @_adHeight < @$mainBody.height()

        $adContainer = $('<div class="sidebar_skyscraper"></div>')
        @$el.append $adContainer

        if @_adsEnabled
            $ad = $('<ins class="adsbygoogle"></ins>')
            $ad.attr 'data-ad-client', Adsense.clientId
            $ad.attr 'data-ad-slot', Adsense.slotIds[@_adCount]
            $ad.css 'height':'600px', 'width':'160px'
            $adContainer.append $ad
            @_loadAds()

        @_adCount += 1
        _.defer => @fillAdPositions()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$mainBody = $('.mainBody')
        @$sidebar = $('.sidebar')
        super

    refresh: ->
        @_waitForPageReadiness()
        super

    # Private Methods #############################################################################

    _loadAds: ->
        return unless @_adsEnabled

        logger.info "Loading #{@_adCount} Google AdSense ads"
        try
            global.adsbygoogle ||= []
            global.adsbygoogle.push {}
        catch e
            logger.warning "Could not load Adsense ad: #{e}"

    _waitForPageReadiness: ->
        return if @_waiting

        if @$mainBody.height() < @_adHeight / 2
            @_waiting = true
            _.delay (=> @_waiting = false; @_waitForPageReadiness()), Duration.normal
        else
            @fillAdPositions()
