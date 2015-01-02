###
Crafting Guide - mod_version_parser.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

Item       = require './item'
Recipe     = require './recipe'
ModVersion = require './mod_version'

########################################################################################################################

module.exports = class ModVersionParser

    @CURRENT_VERSION = '1'

    constructor: ->
        @_parsers =
            '1': new V1

    parse: (data)->
        if not data? then throw new Error 'recipe book data is missing'
        if not data.version? then throw new Error 'version is required'

        parser = @_parsers["#{data.version}"]
        if not parser? then throw new Error "cannot parse version #{data.version} recipe books"

        return parser.parse data

    unparse: (ModVersion, version=ModVersionParser.CURRENT_VERSION)->
        if not ModVersion? then throw new Error 'recipe book is required'

        parser = @_parsers["#{version}"]
        if not parser? then throw new Error "version #{version} is not supported"

        return parser.unparse ModVersion

########################################################################################################################

module.exports.V1 = class V1

    constructor: ->
        @_errorLocation = 'the header information'

    parse: (data)->
        return @_parseModVersion data

    unparse: (ModVersion)->
        return @_unparseModVersion ModVersion

    # Private Methods ##############################################################################

    _parseModVersion: (data)->
        if not data? then throw new Error 'recipe book data is missing'
        if not data.version? then throw new Error 'version is required'
        if not data.mod_name? then throw new Error 'mod_name is required'
        if not data.mod_version? then throw new Error 'mod_version is required'
        if not _.isArray(data.recipes) then throw new Error 'recipes must be an array'

        book             = new ModVersion version:data.version, modName:data.mod_name, modVersion:data.mod_version
        book.description = data.description or ''

        book.rawMaterials = data.raw_materials or []

        for index in [0...data.recipes.length]
            @_errorLocation = "recipe #{index + 1}"
            recipeData = data.recipes[index]
            recipe = @_parseRecipe recipeData
            recipe._originalIndex = index
            book.recipes.push recipe

        return book

    _parseRecipe: (data, options={})->
        if not data? then throw new Error "recipe data is missing for #{@_errorLocation}"
        if not data.output? then throw new Error "#{@_errorLocation} is missing output"

        output = @_parseItemList data.output, field:'output', canBeEmpty:false
        @_errorLocation = "recipe for #{output[0].name}"

        if not data.input? then throw new Error "#{@_errorLocation} is missing input"
        data.tools ?= []

        input  = @_parseItemList data.input, field:'input', canBeEmpty:true
        tools  = @_parseItemList data.tools, field:'tools', canBeEmpty:true

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

    _unparseModVersion: (ModVersion)->
        result = []
        result.push '{\n'
        result.push '    "version": 1,\n'
        result.push '    "mod_name": "' + ModVersion.modName + '",\n'
        result.push '    "mod_version": "' + ModVersion.modVersion + '",\n'
        if ModVersion.description.length > 0
            result.push '    "description": "' + ModVersion.description + '",\n'

        if ModVersion.rawMaterials.length > 0
            result.push '    "raw_materials": [\n'
            firstItem = true
            materials = ModVersion.rawMaterials.slice()
            materials.sort()
            for material in materials
                if not firstItem then result.push ',\n'
                result.push '        "' + material + '"'
                firstItem = false
            result.push '\n    ],\n'

        result.push '    "recipes": [\n'
        recipes = ModVersion.recipes.slice()
        recipes.sort (a, b)->
            if a.name isnt b.name
                return if a.name < b.name then -1 else +1
            if a._originalIndex isnt b._originalIndex
                return if a._originalIndex < b._originalIndex then -1 else +1
            return 0

        firstItem = true
        for recipe in recipes
            result.push if firstItem then '        {\n' else '        }, {\n'
            @_unparseRecipe recipe, result
            firstItem = false
        result.push '        }\n'

        result.push '    ]\n'
        result.push '}'

        return result.join ''

    _unparseRecipe: (recipe, result=[])->
        result.push '            "output": '
        @_unparseItemList recipe.output, result, sort:false

        if recipe.input.length > 0
            result.push ',\n'
            result.push '            "input": '
            @_unparseItemList recipe.input, result

        if recipe.tools.length > 0
            result.push ',\n'
            result.push '            "tools": '
            @_unparseItemList recipe.tools, result

        result.push '\n'
        return result

    _unparseItemList: (itemList, result, options={})->
        options.sort ?= true

        if itemList.length is 0
            result.push '[]'
        else if itemList.length is 1
            item = itemList[0]
            if item.quantity is 1
                result.push '"' + item.name + '"'
            else
                result.push '[[' + item.quantity + ', "' + item.name + '"]]'
        else
            result.push '['

            items = itemList.slice()
            if options.sort
                items.sort (a, b)->
                    if a.quantity isnt b.quantity
                        return if a.quantity > b.quantity then -1 else +1
                    if a.name isnt b.name
                        return if a.name < b.name then -1 else +1
                    return 0

            firstItem = true
            for item in items
                result.push ', ' if not firstItem
                if item.quantity is 1
                    result.push '"' + item.name + '"'
                else
                    result.push '[' + item.quantity + ', "' + item.name + '"]'
                firstItem = false

            result.push ']'

        return result
