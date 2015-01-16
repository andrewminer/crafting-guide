###
Crafting Guide - inventory_parser.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

Inventory     = require './inventory'
Item          = require './item'
StringBuilder = require './string_builder'

########################################################################################################################

module.exports = class InventoryParser

    constructor: (modPack=null)->
        @modPack = modPack

    # Class Methods ################################################################################

    @ITEM_REGEX = /^([0-9]+)(.*)$/

    # Public Methods ###############################################################################

    parse: (data, inventory=null)->
        inventory ?= new Inventory
        return inventory if not data? or data.length is 0

        lines = data.split '\n'
        for line in lines
            match    = InventoryParser.ITEM_REGEX.exec line
            name     = if match? then match[2].trim() else line
            quantity = if match? then parseInt(match[1]) else 1

            if name.length > 0
                inventory.add _.slugify(name), quantity

        return inventory

    unparse: (inventory)->
        if not @modPack? then throw new Error 'this.modPack is needed to unparse'

        builder = new StringBuilder
        for item in inventory.toList()
            if _.isString item
                builder.line @modPack.findName item
            else
                builder.line item[0], ' ', @modPack.findName item[1]

        return builder.toString()