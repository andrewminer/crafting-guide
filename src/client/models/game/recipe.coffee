#
# Crafting Guide - recipe.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel       = require '../base_model'
ItemSlug        = require './item_slug'
Stack           = require './stack'
{StringBuilder} = require 'crafting-guide-common'

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

        attributes.condition            ?= null
        attributes.ignoreDuringCrafting ?= false
        attributes.modVersion           ?= null
        attributes.tools                ?= []
        options.logEvents               ?= false
        super attributes, options

        @_computeQuantities attributes.pattern

        @on c.event.change + ':modVersion', => @_slug = null
        @on c.event.change + ':pattern', => @_patternCache = null

    # Class Methods ################################################################################

    @compareFor: (a, b, itemSlug)->
        if itemSlug?
            aValue = a.itemSlug.matches itemSlug
            bValue = b.itemSlug.matches itemSlug
            if aValue isnt bValue
                return -1 if aValue
                return +1 if bValue

            aValue = a.getQuantityProduced itemSlug
            bValue = b.getQuantityProduced itemSlug
            if aValue isnt bValue
                return if aValue > bValue then -1 else +1

        return 0

    # Public Methods ###############################################################################

    getStackAtSlot: (patternSlot)->
        trueIndex = 0:0, 1:1, 2:2, 3:4, 4:5, 5:6, 6:8, 7:9, 8:10
        patternDigit = @pattern[trueIndex[patternSlot]]
        return null unless patternDigit?
        return null unless patternDigit.match /[0-9]/

        stack = @input[parseInt(patternDigit)]
        return null unless stack?

        return stack

    getQuantityProduced: (itemSlug)->
        total = 0
        for stack in @output
            if stack.itemSlug.matches itemSlug
                total += stack.quantity

        return total

    getQuantityRequired: (itemSlug)->
        total = 0
        for stack, index in @input
            if ItemSlug.equal stack.itemSlug, itemSlug
                total += @_quantities[index] * stack.quantity

        return total

    hasAllTools: (modPack)->
        modPack ?= @modVersion?.mod?.modPack
        return true unless modPack?

        for stack in @tools
            return false unless modPack.findItem stack.itemSlug
        return true

    isConditionSatisfied: (modPack)->
        return true unless @condition?
        modPack ?= @modVersion?.mod?.modPack

        result = false
        if @condition.verb is 'item'
            if modPack?.findItemByName(@condition.noun)?
                result = true
        else if @condition.verb is 'mod'
            modPack.eachMod (mod)->
                if mod.name is @condition.noun
                    result = true

        if @condition.inverted then result = not result
        return result

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

        result = @_produces[itemSlug.qualified] or @_produces[itemSlug.item]
        return result

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

    Object.defineProperties @prototype,

        slug:
            get: ->
                if not @_slug?
                    builder = new StringBuilder
                    delimiterNeeded = false
                    for stack in @input
                        if delimiterNeeded then builder.push ','
                        delimiterNeeded = true

                        if stack.quantity > 1 then builder.push stack.quantity, ' '
                        builder.push stack.itemSlug.qualified

                    builder.push '>'
                    builder.push @pattern
                    builder.push '>'
                    for stack in @tools
                        builder.push stack.itemSlug.qualified
                    builder.push '>'

                    delimiterNeeded = false
                    for stack in @output
                        if delimiterNeeded then builder.push ','
                        delimiterNeeded = true

                        if stack.quantity > 1 then builder.push stack.quantity, ' '
                        builder.push stack.itemSlug.qualified

                    @_slug = builder.toString()

                return @_slug

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") { name:", @name]

        result.push ", input:["
        needsDelimiter = false
        for stack in @input
            if needsDelimiter then result.push ', '
            result.push @getQuantityRequired stack.itemSlug
            result.push ' '
            result.push stack.itemSlug
            needsDelimiter = true
        result.push ']'

        result.push ", output:["
        needsDelimiter = false
        for stack in @output
            if needsDelimiter then result.push ', '
            result.push @getQuantityProduced stack.itemSlug
            result.push ' '
            result.push stack.itemSlug
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

    _computeQuantities: (pattern)->
        quantityMap = {}

        for c in pattern.split ''
            continue if c is '.'
            continue if c is ' '

            if quantityMap[c]?
                quantityMap[c] += 1
            else
                quantityMap[c] = 1

        @_quantities = []
        for i in [0...@input.length]
            @_quantities.push quantityMap["#{i}"]

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
