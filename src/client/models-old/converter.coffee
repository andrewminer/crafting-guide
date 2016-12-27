#
# Crafting Guide - converter.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Item    = require "../models/game/item"
Mod     = require "../models/game/mod"
ModPack = require "../models/game/mod_pack"

########################################################################################################################

module.exports = class Converter

    # Public Methods ###############################################################################

    convert: (id, displayName, oldModPack)->
        modSlugToIdMap = {}
        itemSlugToIdMap = {}

        newModPack = new ModPack id:id, displayName:displayName
        oldModPack.eachMod (oldMod)=>
            newMod = new Mod id:_.uniqueId("mod-"), displayName:oldMod.name, modPack:newModPack
            modSlugToIdMap[oldMod.slug.toString()] = newMod.id

            oldMod.eachItem (oldItem)=>
                newItem = new Item id:_.uniqueId("item-"), displayName:oldItem.name, mod:newMod
                itemSlugToIdMap[oldItem.slug.toString()] = newItem.id

                if oldItem.isGatherable?
                    newItem.isGatherable = oldItem.isGatherable

        oldModPack.eachMod (oldMod)=>
            newMod = newModPack.mods[modSlugToIdMap[oldMod.slug.toString()]]


        return newModPack

    # Private Methods ##############################################################################

    _convertItem: (oldItem, newMod)->

    _convertMod: (oldMod, newModPack)->
        return newMod