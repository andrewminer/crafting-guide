###
Crafting Guide - recipe.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Recipe extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.item? then throw new Error 'attributes.item is required'
        if not attributes.input? then throw new Error 'attributes.input is required'
        if not attributes.output? then throw new Error 'attributes.output is required'

        attributes.pattern ?= @_computeShapelessPattern attributes.input
        attributes.tools   ?= []
        super attributes, options

    Object.defineProperty @prototype, 'name', get:-> @item.name

    # Public Methods ###############################################################################

    getItemSlugAt: (index)->
        patternDigit = @pattern[index]
        return null unless patternDigit?
        return null unless patternDigit.match /[0-9]/

        stack = @input[parseInt(patternDigit)]
        return null unless stack?

        return stack.itemSlug

    make: (inventory, missing)->
        for stack in @input
            itemSlug = stack.itemSlug
            needed   = stack.quantity
            while needed > 0
                if inventory.hasAtLeast itemSlug
                    inventory.remove itemSlug
                else
                    missing.add itemSlug

        for stack in @output
            inventory.add stack.itemSlug, stack.quantity

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

    # Private Methods ##############################################################################

    _computeShapelessPattern: (input)->
        result = []
        for i in [0...input.length]
            stack = input[i]
            for j in [0...stack.quantity]
                result.push "#{i}"
        return result.join ''
