###
Crafting Guide - mod_version_parser.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

Item       = require './item'
ModVersion = require './mod_version'
Recipe     = require './recipe'
Stack      = require './stack'
util       = require 'util'

########################################################################################################################

module.exports = class ModVersionParser

    @CURRENT_VERSION = '1'

    constructor: ->
        @_parsers =
            '1': new V1

    parse: (data)->
        if not data? then throw new Error 'mod description data is missing'
        if not data.version? then throw new Error 'version is required'

        parser = @_parsers["#{data.version}"]
        if not parser? then throw new Error "cannot parse version #{data.version} mod descriptions"

        return parser.parse data

    unparse: (modVersion, version=ModVersionParser.CURRENT_VERSION)->
        if not modVersion? then throw new Error 'modVersion is required'

        parser = @_parsers["#{version}"]
        if not parser? then throw new Error "version #{version} is not supported"

        return parser.unparse modVersion

########################################################################################################################

module.exports.V1 = class V1

    constructor: ->
        @_errorLocation = 'the header information'

    parse: (data)->
        return @_parseModVersion data

    unparse: (modVersion)->
        return @_unparseModVersion modVersion

    # Private Methods ##############################################################################

    _findOrCreateItem: (name)->
        item = @modVersion.findItemByName name
        if not item?
            item = new Item name:name
            @modVersion.addItem item
        return item

    _parseItemList: (data, options={})->
        if not data? then throw new Error "#{@_errorLocation} must have an #{options.field} field"

        if not _.isArray(data) then data = [data]

        result = []
        for name in data
            item = @_findOrCreateItem name
            result.push item
        return result

    _parseModVersion: (data)->
        if not data? then throw new Error 'mod description data is missing'
        if not data.version? then throw new Error 'version is required'
        if not data.mod_name? then throw new Error 'mod_name is required'
        if not data.mod_version? then throw new Error 'mod_version is required'
        if not _.isArray(data.recipes) then throw new Error 'recipes must be an array'

        @modVersion = modVersion = new ModVersion modName:data.mod_name, modVersion:data.mod_version
        modVersion.description = data.description or ''

        @_parseRawMaterials data.raw_materials

        for index in [0...data.recipes.length]
            @_errorLocation = "recipe #{index + 1}"
            recipeData = data.recipes[index]
            @_parseRecipe recipeData

        @modVersion = null
        return modVersion

    _parseRawMaterials: (data, options={})->
        return unless data? and data.length > 0

        results = []
        for name in data
            item = @_findOrCreateItem name
            item.isGatherable = true
            results.push item

    _parseRecipe: (data, options={})->
        if not data? then throw new Error "recipe data is missing for #{@_errorLocation}"
        if not data.output? then throw new Error "#{@_errorLocation} is missing output"

        output = @_parseStackList data.output, field:'output', canBeEmpty:false
        item = output[0].item
        @_errorLocation = "recipe for #{item.name}"

        if not data.input? then throw new Error "#{@_errorLocation} is missing input"
        data.tools ?= []

        input = @_parseStackList data.input, field:'input', canBeEmpty:true
        tools = @_parseItemList data.tools, field:'tools'

        recipe = new Recipe input:input, output:output, tools:tools
        item.addRecipe recipe
        return recipe

    _parseStack: (data, options={})->
        errorBase = "#{options.field} element #{options.index} for #{@_errorLocation}"
        if not data? then throw new Error "#{errorBase} is missing"

        if _.isString(data) then data = [1, data]
        if not _.isArray(data) then throw new Error "#{errorBase} must be an array"

        if data.length is 1 then data.unshift 1
        if data.length isnt 2 then throw new Error "#{errorBase} must have at least one element"
        if not _.isNumber(data[0]) then throw new Error "#{errorBase} must start with a number"

        item = @_findOrCreateItem data[1]
        return new Stack item:item, quantity:data[0]

    _parseStackList: (data, options={})->
        if not data? then throw new Error "#{@_errorLocation} must have an #{options.field} field"

        if not _.isArray(data) then data = [data]
        if data.length is 0 and not options.canBeEmpty
            throw new Error "#{options.field} for #{@_errorLocation} cannot be empty"

        result = []
        for index in [0...data.length]
            stackData = data[index]
            result.push @_parseStack stackData, field:options.field, index:index

        return result

    _parseItemList: (data, options={})->
        if not data? then throw new Error "#{@_errorLocation} must have an #{options.field} field"

        if not _.isArray(data) then data = [data]

        result = []
        for name in data
            item = @_findOrCreateItem name
            result.push item
        return result

    # Un-parsing Methods ###########################################################################

    _unparseModVersion: (modVersion)->
        result = []
        result.push '{\n'
        result.push '    "version": 1,\n'
        result.push '    "mod_name": "' + modVersion.modName + '",\n'
        result.push '    "mod_version": "' + modVersion.modVersion + '",\n'
        if modVersion.description.length > 0
            result.push '    "description": "' + modVersion.description + '",\n'

        rawMaterials = (item.name for slug, item of modVersion.items when item.isGatherable)
        rawMaterials.sort()
        if rawMaterials.length > 0
            result.push '    "raw_materials": [\n'
            firstItem = true
            for material in rawMaterials
                if not firstItem then result.push ',\n'
                result.push '        "' + material + '"'
                firstItem = false
            result.push '\n    ],\n'

        result.push '    "recipes": [\n'

        items = (item for slug, item of modVersion.items when item.isCraftable)
        items.sort (a, b)-> a.compareTo b

        firstItem = true
        for item in items
            for recipe in item.recipes
                result.push if firstItem then '        {\n' else '        }, {\n'
                @_unparseRecipe recipe, result
                firstItem = false
        result.push '        }\n'

        result.push '    ]\n'
        result.push '}'

        return result.join ''

    _unparseRecipe: (recipe, result=[])->
        result.push '            "output": '
        @_unparseStackList recipe.output, result, sort:false

        if recipe.input.length > 0
            result.push ',\n'
            result.push '            "input": '
            @_unparseStackList recipe.input, result

        if recipe.tools.length > 0
            result.push ',\n'
            result.push '            "tools": '
            @_unparseItemList recipe.tools, result

        result.push '\n'
        return result

    _unparseStackList: (stackList, result, options={})->
        options.sort ?= true

        if stackList.length is 0
            result.push '[]'
        else if stackList.length is 1
            stack = stackList[0]
            if stack.quantity is 1
                result.push '"' + stack.name + '"'
            else
                result.push '[[' + stack.quantity + ', "' + stack.name + '"]]'
        else
            result.push '['

            stacks = stackList.slice()
            if options.sort
                stacks.sort (a, b)->
                    if a.quantity isnt b.quantity
                        return if a.quantity > b.quantity then -1 else +1
                    if a.item.name isnt b.item.name
                        return if a.item.name < b.item.name then -1 else +1
                    return 0

            firstItem = true
            for stack in stacks
                result.push ', ' if not firstItem
                if stack.quantity is 1
                    result.push '"' + stack.name + '"'
                else
                    result.push '[' + stack.quantity + ', "' + stack.name + '"]'
                firstItem = false

            result.push ']'

        return result

    _unparseItemList: (itemList, result)->
        if itemList.length is 1
            result.push '"'; result.push itemList[0].name; result.push '"'
        else
            firstItem = true
            for item in itemList
                result.push if firstItem then '["' else '", "'
                result.push item.name
                firstItem = false
            result.push '"]'

        return result
