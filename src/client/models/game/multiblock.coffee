#
# Crafting Guide - multiblock.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'
Inventory = require './inventory'

########################################################################################################################

module.exports = class Multiblock extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.input? then throw new Error 'attributes.input is required'
        if not attributes.layers? then throw new Error 'attributes.layers is required'
        if attributes.layers.length < 1 then throw new Error 'attributes.layers.length must be >= 1'
        super attributes, options

        @_analyzePattern()

    # Public Methods ###############################################################################

    getStackAt: (x, y, z)->
        value = @_stackCache[y]?[z]?[x]
        return null if value is undefined
        return value

    getLayerInventory: (y)->
        @_layerInventories ?= []
        result = @_layerInventories[y]
        if not result? then result = @_layerInventories[y] = new Inventory
        return result

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        depth:
            get: -> @_depth

        height:
            get: -> @_height

        inventory:
            get: -> @_inventory

        width:
            get: -> @_width

    # Private Methods ##############################################################################

    _analyzeLayer: (layer, y, stackCacheLayer)->
        rows = layer.split ' '
        @_depth = Math.max @_depth, rows.length

        for row in rows
            @_width = Math.max @_width, row.length
            stackCacheRow = []
            stackCacheLayer.push stackCacheRow
            @_analyzeRow row, stackCacheRow, @getLayerInventory(y)

    _analyzePattern: ->
        @_depth = @_height = @_width = 0
        @_inventory = new Inventory
        @_stackCache = []

        for layer, y in @layers
            stackCacheLayer = []
            @_stackCache.push stackCacheLayer
            @_analyzeLayer layer, y, stackCacheLayer

        @_height = @layers.length

    _analyzeRow: (row, stackCacheRow, layerInventory)->
        for cell, x in row.split ''
            index = parseInt cell
            stack = null

            if not _.isNaN index
                stack = @input[index]
                @_inventory.add stack.itemSlug, stack.quantity
                layerInventory.add stack.itemSlug, stack.quantity

            stackCacheRow.push stack
