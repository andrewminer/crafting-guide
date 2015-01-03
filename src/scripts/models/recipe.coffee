###
Crafting Guide - recipe.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Recipe extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.input? then throw new Error 'attributes.input is required'
        if not attributes.output? then throw new Error 'attributes.output is required'

        attributes.pattern ?= (i for i in [0...attributes.input.length]).join('')
        attributes.tools   ?= []
        super attributes, options

    Object.defineProperty @prototype, 'name', get:-> @output[0].item.name

    # Public Methods ###############################################################################

    make: (inventory, missing)->
        for stack in @input
            item   = stack.item
            needed = stack.quantity
            while needed > 0
                if inventory.hasAtLeast item.slug
                    inventory.remove item.slug
                else
                    missing.add item.slug

        for stack in @output
            inventory.add stack.item, stack.quantity

        return this

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") { name:", @name]

        result.push ", input:["
        needsDelimiter = false
        for stack in @input
            if needsDelimiter then result.push ', '
            result.push stack.toString()
            needsDelimiter = true
        result.push ']'

        result.push ", output:["
        needsDelimiter = false
        for stack in @output
            if needsDelimiter then result.push ', '
            result.push stack.toString()
            needsDelimiter = true
        result.push ']'

        if @tools.length > 0
            result.push ", tools:["
            needsDelimiter = false
            for stack in @tools
                if needsDelimiter then result.push ', '
                result.push stack.toString()
                needsDelimiter = true
            result.push ']'

        result.push '}'
        return result.join ''
