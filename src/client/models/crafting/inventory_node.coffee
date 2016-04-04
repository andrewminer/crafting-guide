#
# Crafting Guide - inventory_node.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingNode = require './crafting_node'
ItemNode     = require './item_node'

########################################################################################################################

module.exports = class InventoryNode extends CraftingNode

    @::ENTER_METHOD = 'onEnterInventoryNode'
    @::LEAVE_METHOD = 'onLeaveInventoryNode'
    @::TYPE = CraftingNode::TYPES.INVENTORY

    constructor: (options={})->
        if not options.inventory? then throw new Error 'options.inventory is required'
        super options

        @inventory = options.inventory

    # CraftingNode Overrides #######################################################################

    _createChildren: (result=[])->
        @inventory.each (stack)=>
            item = @modPack.findItem stack.itemSlug
            if not item? then throw new Error "Could not find an item for slug: #{stack.itemSlug}"
            result.push new ItemNode modPack:@modPack, item:item, ignoreGatherable:true
        return result

    _checkCompleteness: ->
        for child in @children
            return false unless child.complete
        return true

    _checkValidity: ->
        for child in @children
            return false unless child.valid
        return true

    # Object Overrides #############################################################################

    toString: (options={})->
        options.indent ?= ''
        options.recursive ?= true

        parts = ["#{options.indent}#{@completeText} #{@validText} InventoryNode for #{@inventory}"]
        nextIndent = options.indent + '    '
        if options.recursive
            for child in @children
                parts.push child.toString indent:nextIndent
        return parts.join '\n'
