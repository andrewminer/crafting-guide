###
# Crafting Guide - inventory_parser.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

Inventory = require './inventory'

########################################################################################################################

module.exports = class InventoryParser

    @ITEM_REGEX = /^([0-9]+)(.*)$/

    parse: (data, inventory=null)->
        inventory ?= new Inventory
        return inventory if not data? or data.length is 0

        lines = data.split '\n'
        for line in lines
            match    = InventoryParser.ITEM_REGEX.exec line
            name     = if match? then match[2].trim() else line
            quantity = if match? then parseInt(match[1]) else 1

            if name.length > 0
                inventory.add name, quantity

        return inventory
