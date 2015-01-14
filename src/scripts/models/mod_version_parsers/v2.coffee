###
Crafting Guide - mod_version_parsers/v2.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

Item          = require '../item'
ModVersion    = require '../mod_version'
Recipe        = require '../recipe'
Stack         = require '../stack'
StringBuilder = require '../string_builder'

########################################################################################################################

module.exports = class V2

    @COMMAND = /\ *([^:]*):?(.*)/

    @COMMENT = /([^\\]?)#.*/

    @INTEGER = /[0-9]+/

    @PATTERN = /^[0-9.]{3} ?[0-9.]{3} ?[0-9.]{3}$/

    @STACK = /^([0-9]+) +(.*)$/

    parse: (text)->
        @_modVersionData = {}
        @_lineNumber     = 1

        lines = text.split '\n'
        for i in [0...lines.length]
            @_lineNumber = i + 1
            commands = @_parseLine lines[i]
            for command in commands
                @_execute command

        return @_buildModVersion @_modVersionData

    unparse: (modVersion)->
        builder = new StringBuilder context:modVersion
        @_unparseModVersion builder, modVersion
        return builder.toString()

    # Private Methods ##############################################################################

    _execute: (command)->
        method = this["_command_#{command.name}"]
        if not method? then throw new Error "Unknown command: #{command.name}"
        try
            method.apply this, command.args
        catch e
            e.message = "line #{@_lineNumber}: #{e.message}"
            throw e

    _parseLine: (line)->
        line = line.replace V2.COMMENT, '$1'
        line = line.trim()
        return [] if line.length is 0

        lineParts = (part.trim() for part in line.split(';'))
        commands = []
        for linePart in lineParts
            continue if linePart.length is 0

            match = V2.COMMAND.exec linePart
            if not match? then throw new Error "Expected <command>: <args>, but found: \"#{linePart}\""

            args = []
            args = (s.trim() for s in match[2].split(',')) if match[2]?
            commands.push name:match[1], args:args

        return commands

    # Command Methods ##############################################################################

    _command_description: (descriptionParts...)->
        if @_modVersionData.description? then throw new Error 'duplicate declaration of "description"'
        @_modVersionData.description = descriptionParts.join ', '

    _command_extras: (extraTerms...)->
        if not @_recipeData? then throw new Error 'cannot declare "extras" before "recipe"'
        if @_recipeData.extras? then throw new Error 'duplicate declaration of "extras"'

        @_recipeData.extras = []
        for term in extraTerms
            match = V2.STACK.exec term
            if match?
                @_recipeData.extras.push quantity:parseInt(match[1]), name:match[2]
            else
                @_recipeData.extras.push quantity:1, name:term

    _command_gatherable: (gatherable)->
        if not @_itemData? then throw new Error 'cannot declare "gatherable" before "item"'
        if @_itemData.gatherable? then throw new Error 'duplicate declaration of "gatherable"'
        if not (gatherable in ['yes', 'no']) then throw new Error 'gatherable must be either "yes" or "no"'

        @_itemData.gatherable = (gatherable is 'yes')

    _command_item: (name='')->
        if not name.length > 0 then throw new Error 'the item name cannot be empty'

        @_itemData = name:name, line:@_lineNumber
        @_modVersionData.items ?= []
        @_modVersionData.items.push @_itemData

        @_recipeData = null

    _command_name: (name='')->
        if @_modVersionData.name? then throw new Error 'duplicate declaration of "name"'
        if not name.length > 0 then throw new Error 'the mod name cannot be empty'

        @_modVersionData.name = name

    _command_input: (inputNames...)->
        if not @_recipeData? then throw new Error 'cannot declare "input" before "recipe"'
        if @_recipeData.input? then throw new Error 'duplicate declaration of "input"'

        @_recipeData.input = []
        for name in inputNames
            if name.length is 0 then throw new Error 'input names cannot be empty'
            @_recipeData.input.push name

    _command_pattern: (pattern='')->
        if not @_recipeData? then throw new Error 'cannot declare "pattern" before "recipe"'
        if @_recipeData.pattern? then throw new Error 'duplicate declaration of "pattern"'
        if not V2.PATTERN.test pattern
            throw new Error 'a pattern must have 9 digits using 0-9 for items and "." for an empty spot;
                spaces are optional'

        @_recipeData.pattern = pattern

    _command_quantity: (quantity)->
        if not @_recipeData? then throw new Error 'cannot declare "quantity" before "recipe"'
        if @_recipeData.quantity? then throw new Error 'duplicate declaration of "quantity"'
        if not V2.INTEGER.test(quantity) then throw new Error 'quantity must be an integer'

        @_recipeData.quantity = parseInt quantity

    _command_recipe: ->
        if not @_itemData? then throw new Error 'cannot delcare "recipe" before "item"'

        @_recipeData = line:@_lineNumber
        @_itemData.recipes ?= []
        @_itemData.recipes.push @_recipeData

    _command_schema: -> # do nothing

    _command_tools: (toolNames...)->
        if not @_recipeData? then throw new Error 'cannot declare "tools" before "recipe"'
        if @_recipeData.tools? then throw new Error 'duplicate declaration of "tools"'

        @_recipeData.tools = []
        for name in toolNames
            if name.length is 0 then throw new Error 'tool names cannot be empty'
            @_recipeData.tools.push name

    _command_version: (version='')->
        if @_modVersionData.version? then throw new Error 'duplicate declaration of "version"'
        if version.length is 0 then throw new Error 'version cannot be empty'

        @_modVersionData.version = version

    # Object Creation Methods ######################################################################

    _buildModVersion: (modVersionData)->
        if not modVersionData.name? then throw new Error 'the "name" declaration is required'
        if not modVersionData.version? then throw new Error 'the "version" declaration is required'

        modVersionData.description ?= ''
        modVersionData.items       ?= []

        attributes =
            name:        modVersionData.name
            version:     modVersionData.version
            description: modVersionData.description
        modVersion = new ModVersion attributes

        for itemData in modVersionData.items
            @_buildItem modVersion, itemData

        return modVersion

    _buildItem: (modVersion, itemData)->
        @_lineNumber = itemData.line
        itemData.gatherable ?= false
        itemData.recipes    ?= []

        item = new Item modVersion:modVersion, name:itemData.name, isGatherable:itemData.gatherable

        for recipeData in itemData.recipes
            @_buildRecipe modVersion, item, recipeData

        return item

    _buildRecipe: (modVersion, item, recipeData)->
        @_lineNumber = recipeData.line
        if not recipeData.input? then throw new Error 'the "input" declaration is required'
        if not recipeData.pattern? then throw new Error 'the "pattern" declaration is required'

        recipeData.quantity   ?= 1
        recipeData.extras     ?= []
        recipeData.tools      ?= []

        inputStacks = []
        for name in recipeData.input
            slug = _.slugify name
            modVersion.registerSlug slug, name
            inputStacks.push new Stack itemSlug:slug, quantity:0

        for c in recipeData.pattern
            continue if c is '.'
            continue if c is ' '
            stack = inputStacks[parseInt(c)]
            if not stack? then throw new Error "there is no input #{c} in this recipe"
            stack.quantity += 1

        for i in [0...inputStacks.length]
            stack = inputStacks[i]
            if stack.quantity is 0
                name = modVersion.findName stack.itemSlug
                throw new Error "#{name} is an input for this recipe, but it is not in the pattern"

        outputStacks = [ new Stack itemSlug:item.slug, quantity:recipeData.quantity ]
        for extraData in recipeData.extras
            slug = _.slugify extraData.name
            modVersion.registerSlug slug, extraData.name
            outputStacks.push new Stack itemSlug:slug, quantity:extraData.quantity

        toolStacks = []
        for name in recipeData.tools
            slug = _.slugify name
            modVersion.registerSlug slug, name
            toolStacks.push new Stack itemSlug:slug, quantity:1

        attributes =
            input:        inputStacks
            item:         item
            pattern:      recipeData.pattern
            output:       outputStacks
            tools:        toolStacks

        recipe = new Recipe attributes
        return recipe

    # Un-parsing Methods ###########################################################################

    _unparseModVersion: (builder, modVersion)->
        itemList = _.values modVersion.items
        itemList.sort (a, b)-> a.compareTo b

        builder
            .line 'schema: ', 2
            .line 'name: ', modVersion.name
            .line 'version: ', modVersion.version
            .onlyIf modVersion.description?, => builder.line 'description: ', modVersion.description
            .line()
            .onlyIf itemList.length > 0, =>
                builder.loop itemList, delimiter:'\n', onEach:(b, i)=> @_unparseItem(b, i)
            .outdent()

    _unparseItem: (builder, item)->
        builder
            .line 'item: ', item.name
            .indent()
                .onlyIf item.isGatherable, => builder.line 'gatherable: yes'
                .onlyIf item.recipes.length > 0, =>
                    builder.loop item.recipes, delimiter:'', onEach:(b, r)=> @_unparseRecipe(b, r)
            .outdent()

    _unparseRecipe: (builder, recipe)->
        inputNames = (builder.context.findName(stack.itemSlug) for stack in recipe.input)
        inputNames.sort()

        patternMap = {'.', '.'}
        for i in [0...recipe.input.length]
            stack = recipe.input[i]
            patternMap["#{i}"] = "#{inputNames.indexOf builder.context.findName(stack.itemSlug)}"

        pattern = recipe.pattern or recipe.defaultPattern
        newPattern = []
        for c in pattern.split('')
            newPattern.push patternMap[c]
        newPattern = newPattern.join ''
        newPattern = newPattern.replace /(...)(...)(...)/, '$1 $2 $3'

        quantity = recipe.output[0].quantity

        extraOutputs = recipe.output[0...recipe.output.length]
        extraOutputs.shift()

        builder
            .line 'recipe:'
            .indent()
                .onlyIf extraOutputs.length > 0, =>
                    builder
                        .push 'extras: '
                        .call => @_unparseStackList builder, extraOutputs
                        .line()
                .push 'input: '
                    .loop inputNames
                    .line()
                .line 'pattern: ', newPattern
                .onlyIf quantity > 1, => builder.line 'quantity: ', quantity
                .onlyIf recipe.tools.length > 0, =>
                    builder
                        .push 'tools: '
                        .call => @_unparseStackList builder, recipe.tools
                        .line()
            .outdent()

    _unparseStackList: (builder, stackList)->
        if stackList.length is 1 and stackList[0].quantity is 1
            builder.push builder.context.findName(stackList[0].itemSlug)
        else
            builder.loop stackList, onEach:(b, stack)=>
                builder
                    .onlyIf stack.quantity > 1, => builder.push stack.quantity, ' '
                    .push builder.context.findName stack.itemSlug
