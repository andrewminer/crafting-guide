#
# Crafting Guide - item_selector.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{BaseModel} = require('crafting-guide-common').deprecated
{ItemSlug}  = require('crafting-guide-common').deprecated.game

########################################################################################################################

module.exports = class ItemSelector extends BaseModel

    constructor: (attributes={}, options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.isAcceptable ?= (item)-> return true # accept everything by default
        super attributes, options

        @_isAcceptable  = options.isAcceptable
        @_maxResults    = 100
        @_minHintLength = 3
        @_modPack       = options.modPack
        @_results       = []

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        hint:
            get: ->
                return @_hint

            set: (newHint)->
                oldHint = @_hint
                return if newHint is oldHint

                @_hint = newHint.toLowerCase()

                @trigger c.event.change + ':hint', this, oldHint, newHint
                @_refreshResults()
                @trigger c.event.change, this

        results:
            get: ->
                return @_results

    # Private Methods ##############################################################################

    _computeScore: (name, itemSlug)->
        hintIndex  = 0
        hintLetter = @_hint[hintIndex]
        name       = name.toLowerCase()
        nextScore  = 1
        totalScore = 0

        for nameIndex in [0...name.length] by 1
            if name.charAt(nameIndex) is hintLetter
                totalScore += nextScore
                nextScore += 1
                hintIndex += 1
                if hintIndex is @_hint.length
                    item = @_modPack.findItem itemSlug
                    return 0 unless item?
                    return 0 unless @_isAcceptable item
                    break

                hintLetter = @_hint[hintIndex]
            else
                nextScore = 1

        return 0 if hintIndex < @_hint.length

        totalScore *= @_hint.length / name.length
        return totalScore

    _refreshResults: ->
        oldResults = @_results
        scoredItems = []
        count = 0

        logger.verbose => "Looking for items which match: #{@_hint}"
        if @_hint.length >= @_minHintLength
            @_modPack.eachMod (mod)=>
                return if count >= @_maxResults
                return unless mod.enabled

                mod.eachName (name, itemSlug)=>
                    return if scoredItems.length >= @_maxResults
                    return unless itemSlug.isQualified

                    score = @_computeScore name, itemSlug
                    if score >= @_hint.length
                        scoredItems.push score:score, itemSlug:itemSlug

        scoredItems.sort (a, b)->
            if a.score isnt b.score
                return if a.score > b.score then -1 else +1
            return ItemSlug.compare a.itemSlug, b.itemSlug

        newResults = (e.itemSlug for e in scoredItems)
        @_results = newResults
        @trigger c.event.change + ':results', this, oldResults, newResults
