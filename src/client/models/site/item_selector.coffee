#
# Crafting Guide - item_selector.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Observable} = require("crafting-guide-common").util

########################################################################################################################

module.exports = class ItemSelector extends Observable

    constructor: (modPack, options={})->
        super

        @_isAcceptable  = options.isAcceptable or (item)-> return true # accept everything by default
        @_maxResults    = 100
        @_minHintLength = 3
        @_results       = []

        @modPack = modPack

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        hint:
            get: -> return @_hint
            set: (hint)->
                @triggerPropertyChange "hint", @_hint, hint, ->
                    @_hint = hint?.toLowerCase()
                    @_refreshResults()

        modPack:
            get: -> return @_modPack
            set: (modPack)->
                if not modPack? then throw new Error "modPack is required"
                if @_modPack? then throw new Error "modPack cannot be reassigned"
                @_modPack = modPack

        results:
            get: -> return @_results

    # Private Methods ##############################################################################

    _computeScore: (item)->
        hintIndex  = 0
        hintLetter = @_hint[hintIndex]
        name       = item.displayName.toLowerCase()
        nextScore  = 1
        totalScore = 0

        for nameIndex in [0...name.length] by 1
            if name.charAt(nameIndex) is hintLetter
                totalScore += nextScore
                nextScore += 1
                hintIndex += 1
                if hintIndex is @_hint.length
                    return 0 unless @_isAcceptable item
                    break

                hintLetter = @_hint[hintIndex]
            else
                nextScore = 1

        return 0 if hintIndex < @_hint.length
        return totalScore

    _refreshResults: ->
        scoredItems = []
        count = 0

        if @_hint.length >= @_minHintLength
            for modId, mod of @_modPack.mods
                return if count >= @_maxResults
                return unless mod.isEnabled

                for itemId, item of mod.items
                    score = @_computeScore item
                    if score > 0
                        scoredItems.push score:score, item:item

        scoredItems.sort (a, b)->
            if a.score isnt b.score
                return if a.score > b.score then -1 else +1

            nameA = a.item.displayName
            nameB = b.item.displayName
            if nameA.length isnt nameB.length
                return if nameA.length < nameB.length then -1 else +1

            if nameA isnt nameB
                return if nameA < nameB then -1 else +1

            return 0

        @_results = []
        for element in scoredItems
            @_results.push element.item
            break if @_results.length >= @_maxResults

        @trigger c.event.change + ':results', this

