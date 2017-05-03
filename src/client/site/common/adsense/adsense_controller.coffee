#
# Crafting Guide - adsense_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class AdsenseController

    constructor: ->
        @_adsEnabled = global.env in c.productionEnvs
        @_adsPlaced  = 0
        @_waiting    = false

    # Public Methods ###############################################################################

    fillAdPositions: ->
        adType = @_computeAdType()
        maxAds = c.adsense[adType].slotIds.length - @_adsPlaced
        return if maxAds is 0

        if adType is 'skyscraper'
            placedNewAd = @_createSkyscraperPositions()
        else
            placedNewAd = @_createBannerPositions adType

        if @_adsPlaced < c.adsense[adType].slotIds.length
            duration = if placedNewAd then 0 else c.adsense.readinessCheckInterval
            _.delay (=> @fillAdPositions()), duration
        else
            logger.verbose => "All #{adType} ad positions filled"

    reset: ->
        @_adsPlaced = 0
        @_waitForPageReadiness()

    # Private Methods #############################################################################

    _computeAdType: ->
        return c.adsense.adTypeMap[c.screen.type.compute()]

    _computeAdCount: (adType)->
        result = c.adsense[adType].slotIds.length
        if c.screen.type.compute() is c.screen.type.desktop
            $sidebar = $('.page > .content > .left')
            return 0 unless $sidebar?.length

            available = $sidebar.height() + c.adsense.skyscraper.margin
            available = Math.floor available / (c.adsense.skyscraper.height + c.adsense.skyscraper.margin)
            result = Math.min available, result

        return result

    _createSkyscraperPositions: ->
        $sidebar = $('.page > .content > .left')
        remaining = @_computeAdCount 'skyscraper'
        remaining -= @_adsPlaced
        placedNewAd = false

        while remaining > 0
            $el = $('<div class="view__adsense"></div>')
            $el.addClass c.adsense.skyscraper.cssClass

            if @_adsEnabled
                $ad = $('<ins class="adsbygoogle"></ins>')
                $ad.attr 'data-ad-client', c.adsense.clientId
                $ad.attr 'data-ad-slot', c.adsense.skyscraper.slotIds[@_adsPlaced]
                $el.append $ad
            else
                $el.addClass 'placeholder'

            $sidebar.append $el
            placedNewAd = true
            @_adsPlaced += 1
            remaining -= 1
            logger.info => "Placed skyscraper ad ##{@_adsPlaced}"
            @_loadAd()

        return placedNewAd

    _createBannerPositions: (adType)->
        $pageContent = $('.page > .content > .right')
        remaining = @_computeAdCount adType
        remaining -= @_adsPlaced
        sectionIndex = 0
        placedNewAd = false

        for sectionEl in $pageContent.find('section')
            break unless remaining > 0

            $section = $(sectionEl)
            continue unless $section.is ':visible'

            sectionIndex += 1
            continue if sectionIndex % 2 is 0
            continue if $section.next().hasClass 'view__adsense'

            $el = $('<div class="view__adsense"></div>')
            $el.addClass c.adsense[adType].cssClass

            if @_adsEnabled
                $ad = $('<ins class="adsbygoogle"></ins>')
                $ad.attr 'data-ad-client', c.adsense.clientId
                $ad.attr 'data-ad-slot', c.adsense[adType].slotIds[@_adsPlaced]
                $el.append $ad
            else
                $el.addClass 'placeholder'

            $section.after $el
            placedNewAd = true
            @_adsPlaced += 1
            remaining -= 1
            logger.info => "Placed #{adType} ad ##{@_adsPlaced}"
            @_loadAd()

        return placedNewAd

    _isTooClose: ($priorEl, $el)->
        return false if c.screen.type.compute() is c.screen.type.desktop
        return false if not $priorEl?

        priorBottom = $priorEl.position().top + $priorEl.height()
        currentTop = $el.position().top
        return priorBottom + c.adsense.minimumDistance > currentTop

    _loadAd: ->
        return unless @_adsEnabled

        logger.info "Loading Google AdSense ads"
        try
            global.adsbygoogle ||= []
            global.adsbygoogle.push {}
        catch e
            logger.warning "Could not load Adsense ad: #{e}"

    _waitForPageReadiness: ->
        return if @_waiting
        adCount = @_computeAdCount @_computeAdType()

        if adCount is 0
            logger.trace "Adsense is waiting for room to insert ads"
            @_waiting = true
            _.delay (=> @_waiting = false; @_waitForPageReadiness()), c.adsense.readinessCheckInterval
        else
            logger.verbose "Adsense is ready to fill ads"
            @fillAdPositions()
