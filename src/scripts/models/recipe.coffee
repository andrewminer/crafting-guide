###
Crafting Guide - recipe.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Recipe extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.output? then throw new Error "attributes.output is required"
        attributes.input ?= []
        attributes.tools ?= []
        super attributes, options

    Object.defineProperty @prototype, 'name', get:-> @output[0].name

    # Public Methods ###############################################################################

    make: (inventory, missing)->
        for item in @input
            needed = item.quantity
            while needed > 0
                if inventory.hasAtLeast item.name
                    inventory.remove item.name
                else
                    missing.add item.name

        for item in @output
            inventory.add item.name, item.quantity

        return this

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") { name:", @name]

        result.push ", input:["
        needsDelimiter = false
        for inputItem in @input
            if needsDelimiter then result.push ', '
            result.push inputItem.toString()
            needsDelimiter = true
        result.push ']'

        result.push ", output:["
        needsDelimiter = false
        for outputItem in @output
            if needsDelimiter then result.push ', '
            result.push outputItem.toString()
            needsDelimiter = true
        result.push ']'

        if @tools.length > 0
            result.push ", tools:["
            needsDelimiter = false
            for tool in @tools
                if needsDelimiter then result.push ', '
                result.push tool.toString()
                needsDelimiter = true
            result.push ']'

        result.push '}'
        return result.join ''
