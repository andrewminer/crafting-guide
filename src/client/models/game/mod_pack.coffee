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

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        displayName: # a string containing the user-displayable name of this ModPack
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                if @_displayName is displayName then return
                @_displayName = displayName

        id: # a string which uniquely identifies this ModPack
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                if @_id is id then return
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        mods: # a hash of mod id to Mod containing all the mods which are part of this ModPack
            get: -> return @_mods
            set: -> throw new Error "mods cannot be replaced"

    # Public Methods ###############################################################################

    addMod: (mod)->
        if not mod? then return
        if @_mods[mod.id] is mod then return
        @_mods[mod.id] = mod
        mod.modPack = this

    findItem: (itemId)->
        for modId, mod of @mods
            item = mod.items[itemId]
            return item if item?

        return null

    # Object Overrides #############################################################################

    toString: ->
        return "ModPack:#{@displayName}<#{@id}>"
