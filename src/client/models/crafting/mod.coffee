#
# Crafting Guide - mod.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class Mod

    constructor: (attributes={})->
        @id = attributes.id
        @displayName = attributes.displayName
        @modPack = attributes.modPack

        @_items = {}

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        displayName:
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                return if @_displayName is displayName
                @_displayName = displayName

        id:
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                return if @_id is id
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        items:
            get: -> return @_items
            set: -> throw new Error "items cannot be replaced"

        modPack:
            get: -> return @_modPack
            set: (modPack)->
                if not modPack? then throw new Error "modPack is required"
                if @_modPack is modPack then return
                if @_modPack? then throw new Error "modPack cannot be reassigned"
                @_modPack = modPack
                @_modPack.addMod this

    # Public Methods ###############################################################################

    addItem: (item)->
        if not item? then return
        if @_items[item.id] is item then return
        @_items[item.id] = item
        item.mod = this

    # Object Overrides #############################################################################

    toString: ->
        return "Mod:#{@displayName}<#{@id}>"
