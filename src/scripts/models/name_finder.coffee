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
            c = a.mod.compareTo b.mod
            if c isnt 0 then return c

            return 0 if a.label is b.label
            return if a.label < b.label then -1 else +1

        names = names[0...@limit]

        return names

    # Private Methods ##############################################################################

    _findNames: (nameHint=null)->
        names   = []
        nameMap = {}
        hintRegex = new RegExp(nameHint, 'i') if nameHint?

        @modPack.eachMod (mod)=>
            return unless mod.enabled or @includeDisabledMods

            mod.eachName (name, itemSlug)=>
                return if nameMap[name]?

                if not @includeGatherable
                    item = mod.findItem itemSlug
                    return unless item? and item.isCraftable

                scanName = "#{mod.name} : #{name}"
                if hintRegex?
                    return unless hintRegex.test scanName

                nameMap[name] = name
                names.push value:name, label:scanName, mod:mod

        return names
