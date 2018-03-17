#
# Crafting Guide - item_selector.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'
ItemSlug  = require '../game/item_slug'

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

    _isMatch: (name, itemSlug)->
        hintIndex  = 0
        hintLetter = @_hint[hintIndex]
        name       = name.toLowerCase()

        for nameIndex in [0...name.length] by 1
            if name.charAt(nameIndex) is hintLetter
                hintIndex += 1
                if hintIndex is @_hint.length
                    item = @_modPack.findItem itemSlug
                    return false unless item?
                    return @_isAcceptable item
                hintLetter = @_hint[hintIndex]

        return false

    _refreshResults: ->
        oldResults = @_results
        newResults = {}
        count = 0

        logger.verbose => "Looking for items which match: #{@_hint}"
        if @_hint.length >= @_minHintLength
            @_modPack.eachMod (mod)=>
                return if count >= @_maxResults
                return unless mod.enabled

                mod.eachName (name, itemSlug)=>
                    return if count >= @_maxResults

                    if @_isMatch name, itemSlug
                        if itemSlug.isQualified
                            newResults[itemSlug] = itemSlug
                            count += 1

        newResults = _.values(newResults)
        newResults.sort ItemSlug.compare

        @_results = newResults
        @trigger c.event.change + ':results', this, oldResults, newResults
