###
Crafting Guide - name_finder.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class NameFinder

    constructor: (modPack, options={})->
        if not modPack? then throw new Error 'modPack is required'

        options.includeGatherable   ?= false
        options.includeDisabledMods ?= false
        options.limit               ?= 25

        @includeDisabledMods = options.includeDisabledMods
        @includeGatherable   = options.includeGatherable
        @limit               = options.limit
        @modPack             = modPack
        @names               = []
        @_nameMap            = {}

    # Public Methods ###############################################################################

    search: (nameHint='')->
        nameHint = null if nameHint.trim() is ''
        nameHint = nameHint.toLowerCase() if nameHint?
        names = @_findNames nameHint

        names.sort (a, b)->
            c = a.modVersion.compareTo b.modVersion
            if c isnt 0 then return c

            return 0 if a.label is b.label
            return if a.label < b.label then -1 else +1

        names = names[0...@limit]

        return names

    # Private Methods ##############################################################################

    _isMatch: (name, hint)->
        nameWords = name.split ' '
        hintWords = hint.split ' '

        for hintWord in hintWords
            while true
                return false if nameWords.length is 0
                nameWord = nameWords.shift()
                break if nameWord.indexOf(hintWord) is 0

        return true

    _findNames: (nameHint=null)->
        names   = []
        nameMap = {}

        @modPack.eachModVersion (modVersion)=>
            return unless modVersion.enabled or @includeDisabledMods

            modVersion.eachName (name, slug)=>
                return if nameMap[name]

                item = modVersion.findItem slug
                if not @includeGatherable
                    return unless item? and (not item.isGatherable)

                scanName = "#{modVersion.name} : #{name}"
                if nameHint?
                    return unless @_isMatch scanName.toLowerCase(), nameHint

                nameMap[name] = name
                names.push value:name, label:scanName, modVersion:modVersion

        return names
