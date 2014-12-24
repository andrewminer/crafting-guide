###
# Crafting Guide - recipe_book_parser.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

Item       = require './item'
Recipe     = require './recipe'
RecipeBook = require './recipe_book'

########################################################################################################################

module.exports = class RecipeBookParser

    constructor: ->
        @_parsers =
            '1': new V1

    parse: (data)->
        if not data? then throw new Error 'recipe book data is missing'
        if not data.version? then throw new Error 'version is required'

        parser = @_parsers["#{data.version}"]
        if not parser?
            throw new Error "cannot parse version #{data.version} recipe books"

        return parser.parse data

########################################################################################################################

module.exports.V1 = class V1

    constructor: ->
        @_errorLocation = 'the header information'

    parse: (data)->
        return @_parseRecipeBook data

    # Private Methods ##############################################################################

    _parseRecipeBook: (data)->
        if not data? then throw new Error 'recipe book data is missing'
        if not data.version? then throw new Error 'version is required'
        if not data.mod_name? then throw new Error 'mod_name is required'
        if not data.mod_version? then throw new Error 'mod_version is required'
        if not _.isArray(data.recipes) then throw new Error 'recipes must be an array'

        book             = new RecipeBook version:data.version, modName:data.mod_name, modVersion:data.mod_version
        book.description = data.description or ''

        for index in [0...data.recipes.length]
            @_errorLocation = "recipe #{index + 1}"
            recipeData = data.recipes[index]
            book.recipes.push @_parseRecipe recipeData

        return book

    _parseRecipe: (data, options={})->
        if not data? then throw new Error "recipe data is missing for #{@_errorLocation}"
        if not data.output? then throw new Error "#{@_errorLocation} is missing output"
        if not data.input? then throw new Error "#{@_errorLocation} is missing input"

        output = @_parseItemList data.output, field:'output', canBeEmpty:false
        @_errorLocation = "recipe for output[0].name"

        data.tools ?= []
        input  = @_parseItemList data.input,  field:'input', canBeEmpty:false
        tools  = @_parseItemList data.tools,  field:'tools', canBeEmpty:true

        return new Recipe input:input, output:output, tools:tools

    _parseItemList: (data, options={})->
        if not data? then throw new Error "#{@_errorLocation} must have an #{options.field} field"

        if not _.isArray(data) then data = [data]
        if data.length is 0 and not options.canBeEmpty
            throw new Error "#{options.field} for #{@_errorLocation} cannot be empty"

        result = []
        for index in [0...data.length]
            itemData = data[index]
            result.push @_parseItem itemData, field:options.field, index:index

        return result

    _parseItem: (data, options={})->
        errorBase = "#{options.field} element #{options.index} for #{@_errorLocation}"
        if not data? then throw new Error "#{errorBase} is missing"

        if _.isString(data) then data = [1, data]
        if not _.isArray(data) then throw new Error "#{errorBase} must be an array"

        if data.length is 1 then data.unshift 1
        if data.length isnt 2 then throw new Error "#{errorBase} must have at least one element"
        if not _.isNumber(data[0]) then throw new Error "#{errorBase} must start with a number"

        return new Item quantity:data[0], name:data[1]
