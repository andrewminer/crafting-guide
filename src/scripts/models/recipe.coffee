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
        if attributes.item?
            attributes.name = attributes.item.name
            attributes.slug = attributes.item.slug
            attributes.output ?= [new Stack slug:attributes.item.slug, quantity:1]

        if not attributes.name? then throw new Error 'attributes.name is required'
        if not attributes.input? then throw new Error 'attributes.input is required'
        if not attributes.pattern? then throw new Error 'attributes.pattern is required'

        attributes.item    ?= null
        attributes.output  ?= [new Stack slug:_.slugify(attributes.name), quantity:1]
        attributes.pattern = @_parsePattern attributes.pattern
        attributes.slug    ?= attributes.output[0].slug
        attributes.tools   ?= []
        options.logEvents  ?= false
        super attributes, options

    # Public Methods ###############################################################################

    getItemSlugAt: (patternSlot)->
        trueIndex = 0:0, 1:1, 2:2, 3:4, 4:5, 5:6, 6:8, 7:9, 8:10
        patternDigit = @pattern[trueIndex[patternSlot]]
        return null unless patternDigit?
        return null unless patternDigit.match /[0-9]/

        stack = @input[parseInt(patternDigit)]
        return null unless stack?

        return stack.slug

    doesProduce: (itemSlug)->
        for stack in @output
            return true if stack.slug is itemSlug
        return false

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
