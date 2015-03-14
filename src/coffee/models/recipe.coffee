###
Crafting Guide - recipe.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel     = require './base_model'
{Event}       = require '../constants'
Stack         = require './stack'
StringBuilder = require './string_builder'

########################################################################################################################

module.exports = class Recipe extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.input? then throw new Error 'attributes.input is required'
        if not attributes.pattern? then throw new Error 'attributes.pattern is required'

        if attributes.itemSlug? and not attributes.output?
            attributes.output = [new Stack itemSlug:attributes.itemSlug, quantity:1]
        else if attributes.output? and not attributes.itemSlug?
            if attributes.output.length is 0 then throw new Error 'attributes.output cannot be empty'
            attributes.itemSlug = attributes.output[0].itemSlug
        else
            throw new Error 'attributes.itemSlug or attributes.output is required'

        attributes.pattern = @_parsePattern attributes.pattern

        attributes.modVersion ?= null
        attributes.tools      ?= []
        options.logEvents     ?= false
        super attributes, options

        @on Event.change + ':modVersion', => @_slug = null

    # Class Methods ################################################################################

    @compareFor: (a, b, itemSlug)->
        if itemSlug?
            aValue = a.itemSlug.matches itemSlug
            bValue = b.itemSlug.matches itemSlug
            if aValue isnt bValue
                return -1 if aValue
                return +1 if bValue

            aValue = a.getQuantityProducedOf itemSlug
            bValue = b.getQuantityProducedOf itemSlug
            if aValue isnt bValue
                return if aValue > bValue then -1 else +1

        aValue = a.getOutputCount()
        bValue = b.getOutputCount()
        if aValue isnt bValue
            return if aValue > bValue then -1 else +1

        aValue = a.tools.length
        bValue = b.tools.length
        if aValue isnt bValue
            return if aValue < bValue then -1 else +1

        aValue = a.getInputCount()
        bValue = b.getInputCount()
        if aValue isnt bValue
            return if aValue < bValue then -1 else +1

        return 0

    # Public Methods ###############################################################################

    getInputCount: ->
        result = 0
        for stack in @input
            result += stack.quantity
        return result

    getItemSlugAt: (patternSlot)->
        trueIndex = 0:0, 1:1, 2:2, 3:4, 4:5, 5:6, 6:8, 7:9, 8:10
        patternDigit = @pattern[trueIndex[patternSlot]]
        return null unless patternDigit?
        return null unless patternDigit.match /[0-9]/

        stack = @input[parseInt(patternDigit)]
        return null unless stack?

        return stack.itemSlug

    getOutputCount: ->
        result = 0
        for stack in @output
            result += stack.quantity
        return result

    getQuantityProducedOf: (itemSlug)->
        for stack in @output
            if stack.itemSlug.matches itemSlug
                return stack.quantity

        return 0

    isPassThroughFor: (itemSlug)->
        amountCreated = 0
        for stack in @output
            if stack.itemSlug.matches itemSlug
                amountCreated += stack.quantity

        for stack in @input
            if stack.itemSlug.matches itemSlug
                amountCreated -= stack.quantity

        return amountCreated <= 0

    produces: (itemSlug)->
        if not @_produces?
            @_produces = {}

            for stack in @output
                actuallyProduces = not @isPassThroughFor stack.itemSlug
                @_produces[stack.itemSlug.qualified] = actuallyProduces
                @_produces[stack.itemSlug.item] = actuallyProduces

        return @_produces[itemSlug.qualified] or @_produces[itemSlug.item]

    requires: (itemSlug)->
        for stack in @input
            if stack.itemSlug.matches itemSlug
                return true
        return false

    requiresTool: (itemSlug)->
        for stack in @tools
            if stack.itemSlug.matches itemSlug
                return true

    # Property Methods #############################################################################

    getSlug: ->
        if not @_slug?
            builder = new StringBuilder
            builder
                .loop(@input, delimiter:',', onEach:(b, stack)-> b.push stack.itemSlug.qualified)
                .onlyIf @tools.length > 0, (b)=>
                    b.push(' + ').loop(@tools, delimiter:',', onEach:(b, stack)-> b.push stack.itemSlug.qualified)
                .push(' => ')
                .loop(@output, delimiter:',', onEach:(b, stack)-> b.push stack.itemSlug.qualified)
            @_slug = builder.toString()

        return @_slug

    Object.defineProperties @prototype,
        slug: {get:@prototype.getSlug}

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
