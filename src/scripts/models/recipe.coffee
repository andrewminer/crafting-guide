###
Crafting Guide - recipe.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
Stack     = require './stack'

########################################################################################################################

module.exports = class Recipe extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.input? then throw new Error 'attributes.input is required'
        if not attributes.item? then throw new Error 'attributes.item is required'

        attributes.output  ?= [new Stack itemSlug:attributes.item.slug]
        attributes.pattern = @_parsePattern attributes.pattern
        attributes.tools   ?= []
        super attributes, options

        @item.addRecipe this

        Object.defineProperties this,
            'defaultPattern': { get: -> @_computeDefaultPattern() }
            'name':           { get: -> @item.name }
            'slug':           { get: -> @item.slug }

    # Public Methods ###############################################################################

    getItemSlugAt: (index)->
        pattern = if @pattern? then @pattern else @_computeDefaultPattern()

        trueIndex = 0:0, 1:1, 2:2, 3:4, 4:5, 5:6, 6:8, 7:9, 8:10
        patternDigit = pattern[trueIndex[index]]
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

    _parsePattern: (pattern)->
        return unless pattern?

        pattern = pattern.replace /\ /g, ''
        return if pattern.length is 0

        pattern = pattern.replace /[^0-9]/g, '.'

        array = pattern.split ''
        array = array[0...9]
        while array.length isnt 9
            array.push '.'

        pattern = array.join ''
        pattern = pattern.replace /(...)(...)(...)/, '$1 $2 $3'
        return pattern

    _computeDefaultPattern: ->
        itemCount = @input.length
        slotCount = _.reduce @input, ((total, stack)-> total + stack.quantity), 0

        return '... .0. ...' if itemCount is 1 and slotCount is 1
        return '00. 00. ...' if itemCount is 1 and slotCount is 4
        return '000 000 000' if itemCount is 1 and slotCount is 9

        result = ['.', '.', '.', '.', '.', '.', '.', '.', '.']
        indexes = [4, 7, 1, 3, 5, 6, 8, 0, 2]

        for i in [0...@input.length]
            stack = @input[i]
            for j in [0...stack.quantity]
                index = indexes.shift()
                result[index] = "#{i}"

        pattern = result.join ''
        pattern = pattern.replace /(...)(...)(...)/, '$1 $2 $3'
        return pattern
