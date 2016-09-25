#
# Crafting Guide - mod_pack.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class ModPack

    constructor: (attributes={})->
        @id = attributes.id
        @displayName = attributes.displayName

        @_mods = {}
        @_oreDict = {}

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        displayName:
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                if @_displayName is displayName then return
                @_displayName = displayName

        id:
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                if @_id is id then return
                if @_id? then throw new Error "id cannot be reassigned"

        mods:
            get: -> return @_mods
            set: -> throw new Error "mods cannot be replaced"

    # Public Methods ###############################################################################

    addMod: (mod)->
        if not mod? then return
        if @_mods[mod.id] is mod then return
        @_mods[mod.id] = mod
        mod.modPack = this

    # Object Overrides #############################################################################

    toString: ->
        return "ModPack:#{@displayName}<#{@id}>"
