###
Crafting Guide - item_selector.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
ItemSlug = require './item_slug'

########################################################################################################################

module.exports = class ItemSelector extends BaseModel

    constructor: (attributes={}, options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'

        super attributes, options

        @_maxResults    = 100
        @_minHintLength = 3
        @_modPack       = options.modPack
        @_results       = []

    # Property Methods #############################################################################

    getHint: ->
        return @_hint

    setHint: (newHint)->
        oldHint = @_hint
        return if newHint is oldHint

        @_hint = newHint.toLowerCase()

        @trigger Event.change + ':hint', this, oldHint, newHint
        @_refreshResults()
        @trigger Event.change, this

    getResults: ->
        return @_results

    Object.defineProperties @prototype,
        hint:    {get:@prototype.getHint,    set:@prototype.setHint}
        results: {get:@prototype.getResults}

    # Private Methods ##############################################################################

    _isMatch: (name)->
        hintIndex  = 0
        hintLetter = @_hint[hintIndex]
        name       = name.toLowerCase()

        for nameIndex in [0...name.length] by 1
            if name.charAt(nameIndex) is hintLetter
                hintIndex += 1
                return true if hintIndex is @_hint.length
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

                mod.eachName (name, itemSlug)=>
                    return if count >= @_maxResults

                    if @_isMatch name
                        if itemSlug.isQualified
                            newResults[itemSlug] = itemSlug
                            count += 1

        newResults = _.values(newResults)
        newResults.sort ItemSlug.compare

        @_results = newResults
        @trigger Event.change + ':results', this, oldResults, newResults
