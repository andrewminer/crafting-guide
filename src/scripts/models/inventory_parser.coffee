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

    @STACK_DELIMITER = ':'

    @ITEM_DELIMITER = '.'

    # Public Methods ###############################################################################

    parse: (data, inventory=null)->
        inventory ?= new Inventory
        return inventory if not data? or data.length is 0

        stacks = data.split InventoryParser.STACK_DELIMITER
        for stackText in stacks
            stackParts = stackText.split InventoryParser.ITEM_DELIMITER
            if stackParts.length is 2
                quantity = parseInt stackParts[0]
                slug = _.slugify stackParts[1]
            else if stackParts.length is 1
                quantity = 1
                slug = _.slugify stackParts[0]
            else
                throw new Error "expected #{stackText} to have 0 or 1 parts"

            if slug.length > 0
                inventory.add slug, quantity

        return inventory

    unparse: (inventory)->
        if not @modPack? then throw new Error 'this.modPack is needed to unparse'

        parts = []
        inventory.each (stack)->
            if stack.quantity is 1
                parts.push stack.slug
            else
                parts.push "#{stack.quantity}#{InventoryParser.ITEM_DELIMITER}#{stack.slug}"

        return parts.join InventoryParser.STACK_DELIMITER
