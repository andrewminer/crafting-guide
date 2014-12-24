###
# Crafting Guide - recipe.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Recipe extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.output? then throw new Error "attributes.output is required"
        if not attributes.input? then throw new Error "attributes.input is required"
        attributes.tools ?= []
        super attributes, options

        Object.defineProperty this, 'name', get:-> @output[0].name

    # Object Overrides #############################################################################

    toString: ->
        result = [@constructor.name, " (", @cid, ") { name:", @name]

        result.push ", input:["
        needsDelimiter = false
        for inputItem in @input
            if needsDelimiter then result.push ', '
            result.push inputItem.toString()
            needsDelimiter = false
        result.push ']'

        result.push ", output:["
        needsDelimiter = false
        for outputItem in @output
            if needsDelimiter then result.push ', '
            result.push outputItem.toString()
            needsDelimiter = false
        result.push ']'

        if @tools.length > 0
            result.push ", tools:["
            needsDelimiter = false
            for tool in @tools
                if needsDelimiter then result.push ', '
                result.push tool.toString()
                needsDelimiter = false
            result.push ']'

        result.push '}'
        return result.join ''
