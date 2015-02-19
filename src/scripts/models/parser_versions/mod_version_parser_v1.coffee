###
Crafting Guide - mod_version_parser_v2.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

CommandParserVersionBase = require './command_parser_version_base'
Item                     = require '../item'
ItemSlug                 = require '../item_slug'
ModVersion               = require '../mod_version'
Recipe                   = require '../recipe'
Stack                    = require '../stack'
StringBuilder            = require '../string_builder'

########################################################################################################################

module.exports = class ModVersionParserV1 extends CommandParserVersionBase

    # Class Methods ################################################################################

    @INTEGER = /[0-9]+/

    @PATTERN = /^[0-9.]{3} ?[0-9.]{3} ?[0-9.]{3}$/

    @STACK = /^([0-9]+) +(.*)$/

    # CommandParserVersionBase Overrides ###########################################################

    _buildModel: (rawData, model)->
        @_buildModVersion rawData, model

    _unparseModel: (builder, model)->
        @_unparseModVersion builder, model

    # Command Methods ##############################################################################

    _command_extras: (extraTerms...)->
        if not @_recipeData? then throw new Error 'cannot declare "extras" before "recipe"'
        if @_recipeData.extras? then throw new Error 'duplicate declaration of "extras"'

        @_recipeData.extras = []
        for term in extraTerms
            match = ModVersionParserV1.STACK.exec term
            if match?
                @_recipeData.extras.push quantity:parseInt(match[1]), name:match[2]
            else
                @_recipeData.extras.push quantity:1, name:term

    _command_gatherable: (gatherable)->
        if not @_itemData? then throw new Error 'cannot declare "gatherable" before "item"'
        if @_itemData.gatherable? then throw new Error 'duplicate declaration of "gatherable"'
        if not (gatherable in ['yes', 'no']) then throw new Error 'gatherable must be either "yes" or "no"'

        @_itemData.gatherable = (gatherable is 'yes')

    _command_group: (group)->
        if group.length is 0 then throw new Error 'a group name cannot be empty'
        @_rawData.group = group

    _command_item: (name='')->
        if not name.length > 0 then throw new Error 'the item name cannot be empty'

        @_itemData = name:name, line:@_lineNumber, group:@_rawData.group, type:'new'
        @_rawData.items ?= {}
        @_rawData.items[name] = @_itemData

        @_recipeData = null

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
        if not ModVersionParserV1.PATTERN.test pattern
            throw new Error 'a pattern must have 9 digits using 0-9 for items and "." for an empty spot;
                spaces are optional'

        @_recipeData.pattern = pattern

    _command_quantity: (quantity)->
        if not @_recipeData? then throw new Error 'cannot declare "quantity" before "recipe"'
        if @_recipeData.quantity? then throw new Error 'duplicate declaration of "quantity"'
        if not ModVersionParserV1.INTEGER.test(quantity) then throw new Error 'quantity must be an integer'

        @_recipeData.quantity = parseInt quantity

    _command_recipe: ->
        if not @_itemData? then throw new Error 'cannot delcare "recipe" before "item"'

        @_recipeData = line:@_lineNumber
        @_itemData.recipes ?= []
        @_itemData.recipes.push @_recipeData

    _command_tools: (toolNames...)->
        if not @_recipeData? then throw new Error 'cannot declare "tools" before "recipe"'
        if @_recipeData.tools? then throw new Error 'duplicate declaration of "tools"'

        @_recipeData.tools = []
        for name in toolNames
            if name.length is 0 then throw new Error 'tool names cannot be empty'
            @_recipeData.tools.push name

    _command_update: (name='')->
        if not name.length > 0 then throw new 'the item name cannot be empty'

        @_itemData   = name:name, line:@_lineNumber, type:'update'
        @_recipeData = null

        @_rawData.items ?= {}
        @_rawData.items[name] = @_itemData

    # Object Creation Methods ######################################################################

    _buildModVersion: (modVersionData, modVersion)->
        modVersionData.items ?= []

        for itemName, itemData of modVersionData.items
            @_handleErrors @_buildItem, modVersion, itemData

        modVersion.sort()
        return modVersion

    _buildItem: (modVersion, itemData)->
        @_lineNumber = itemData.line
        itemData.gatherable ?= false
        itemData.recipes    ?= []

        if itemData.type is 'new'
            item = new Item name:itemData.name, isGatherable:itemData.gatherable, group:itemData.group
            modVersion.addItem item
            itemData.slug = item.slug
        else
            itemData.slug = ItemSlug.slugify itemData.name
            modVersion.registerName itemData.slug, itemData.name

        for recipeData in itemData.recipes
            @_handleErrors @_buildRecipe, modVersion, itemData, recipeData

        return item

    _buildRecipe: (modVersion, itemData, recipeData)->
        @_lineNumber = recipeData.line
        if not recipeData.input? then throw new Error 'the "input" declaration is required'
        if not recipeData.pattern? then throw new Error 'the "pattern" declaration is required'

        createSlug = (name)=>
            item = @_rawData.items[name]
            if item?
                slug = new ItemSlug modVersion.modSlug, _.slugify name
            else
                slug = new ItemSlug _.slugify name
            modVersion.registerName slug, name
            return slug

        recipeData.quantity   ?= 1
        recipeData.extras     ?= []
        recipeData.tools      ?= []

        inputStacks = []
        for name in recipeData.input
            inputSlug = createSlug name
            inputStacks.push new Stack itemSlug:inputSlug, quantity:0

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

        outputStacks = [ new Stack itemSlug:itemData.slug, quantity:recipeData.quantity ]
        for extraData in recipeData.extras
            outputSlug = createSlug extraData.name
            outputStacks.push new Stack itemSlug:outputSlug, quantity:extraData.quantity

        toolStacks = []
        for name in recipeData.tools
            toolSlug = createSlug name
            toolStacks.push new Stack itemSlug:toolSlug, quantity:1

        recipe = new Recipe
            input:   inputStacks
            output:  outputStacks
            pattern: recipeData.pattern
            tools:   toolStacks

        modVersion.addRecipe recipe
        return recipe

    # Un-parsing Methods ###########################################################################

    _unparseModVersion: (builder, modVersion)->
        builder
            .line 'schema: ', 1
            .line()

        modVersion.eachGroup (group)=>
            @_unparseGroup builder, modVersion, group

        for itemSlugText, recipeList of modVersion.findExternalRecipes()
            builder
                .line 'update: ', modVersion.findName ItemSlug.slugify(itemSlugText)
                .indent()
                .loop(recipeList, delimiter:'\n\n', onEach:(b, r)=> @_unparseRecipe(b, r))
                .outdent()

    _unparseGroup: (builder, modVersion, group)->
        if group isnt Item.Group.Other
            builder
                .line 'group: ', group
                .line()
                .indent()

        modVersion.eachItemInGroup group, (item)=>
            @_unparseItem builder, modVersion, item
            builder.line()

        if group isnt Item.Group.Other
            builder.outdent()

    _unparseItem: (builder, modVersion, item)->
        recipes = modVersion.findRecipes item.slug

        builder
            .line 'item: ', item.name
            .indent()
                .onlyIf item.isGatherable, => builder.line 'gatherable: yes'
                .onlyIf recipes.length > 0, =>
                    builder.loop recipes, delimiter:'', onEach:(b, r)=> @_unparseRecipe(b, r)
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
