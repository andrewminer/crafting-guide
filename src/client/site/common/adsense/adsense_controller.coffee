#
# Crafting Guide - adsense_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'

########################################################################################################################

module.exports = class AdsenseController extends BaseController

    constructor: (options={})->
        options.templateName = 'common/adsense'
        super options

        @_adsEnabled = global.env in c.productionEnvs
        @_adCount    = 0
        @_waiting    = false

    # Public Methods ###############################################################################

    fillAdPositions: ->
        if @_adCount > 0
            return unless @$sidebar and @$mainBody
            return unless @_adCount < @_computeMaxAds()
            return unless @_adCount < c.adsense.slotIds.length

        $adContainer = $('<div class="skyscraper"></div>')
        @$el.append $adContainer

        if @_adsEnabled
            $ad = $('<ins class="adsbygoogle"></ins>')
            $ad.attr 'data-ad-client', c.adsense.clientId
            $ad.attr 'data-ad-slot', c.adsense.slotIds[@_adCount]
            $adContainer.append $ad
            @_loadAds()

        @_adCount += 1
        _.defer => @fillAdPositions()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$mainBody = $('.page > .content > .right')
        @$sidebar = $('.page > .content > .left')
        super

    refresh: ->
        @_waitForPageReadiness()
        super

    # Private Methods #############################################################################

    _computeMaxAds: ->
        return null unless @$sidebar
        result = Math.floor @$sidebar.height() / (c.adsense.skyscraper.height + c.adsense.skyscraper.margin)
        return result

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

        if @$sidebar.height() < c.adsense[@model].height / 2
            logger.verbose "Adsense is waiting for room to insert ads"
            @_waiting = true
            _.delay (=> @_waiting = false; @_waitForPageReadiness()), c.duration.normal
        else
            logger.verbose "Adsense is ready to fill ads"
            @fillAdPositions()
