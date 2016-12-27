#
# Crafting Guide - mod_version_parser_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CommandParserVersionBase = require './command_parser_version_base'
Item                     = require '../game/item'
ItemSlug                 = require '../game/item_slug'
ModVersion               = require '../game/mod_version'
Multiblock               = require '../game/multiblock'
Recipe                   = require '../game/recipe'
Stack                    = require '../game/simple_stack'
{StringBuilder}          = require 'crafting-guide-common'

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
        if @_recipeData.output.length isnt 1 then throw new Error 'duplicate declaration of "extras"'

        for term in extraTerms
            @_recipeData.output.push @_parseStack term

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

    _command_ignoreDuringCrafting: (value)->
        if not @_recipeData? then throw new Error 'cannot declare "ignoreDuringCrafting" before "recipe"'
        if @_recipeData.ignoreDuringCrafting? then throw new Error 'duplicate declaration of "ignoreDuringCrafting"'
        if not (value in ['yes', 'no']) then throw new Error 'ignoreDuringCrafting must be either "yes" or "no"'

        @_recipeData.ignoreDuringCrafting = (value is 'yes')

    _command_input: (stackDescriptions...)->
        activeData = if @_recipeData? then @_recipeData else @_multiblockData

        if not activeData? then throw new Error 'cannot declare "input" before "recipe" or "multiblock"'
        if activeData.input.length isnt 0 then throw new Error 'duplicate declaration of "input"'

        for stackDescription in stackDescriptions
            activeData.input.push @_parseStack stackDescription

    _command_layer: (layerText)->
        if not @_multiblockData? then throw new Error 'cannot declare "layer" before "multiblock"'
        if not layerText? then throw new Error 'cannot have an empty layer'
        if layerText.length is 0 then throw new Error 'cannot have an empty layer'

        @_multiblockData.layers.push layerText

    _command_multiblock: ->
        if not @_itemData? then throw new Error 'cannot declare "multiblock" before "item"'
        if @_itemData.multiblockData? then throw new Error 'duplicate declaration of "multiblock"'

        @_recipeData = null
        @_multiblockData = input:[], layers:[], line:@_lineNumber
        @_itemData.multiblockData = @_multiblockData

    _command_onlyIf: (condition)->
        words = condition.split ' '
        if words.length < 2 then throw new Error 'condition must include a verb followed by a noun'

        inverted = false
        if words[0] is 'not'
            inverted = true
            words.shift()

        verb = words[0]
        noun = words[1..].join ' '

        if not (verb in ['item', 'mod']) then throw new Error "unknown verb: #{verb}"
        @_recipeData.condition = verb:verb, noun:noun, inverted:inverted

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

        @_recipeData.quantity = quantity
        @_recipeData.output[0].quantity = parseInt quantity

    _command_recipe: ->
        if not @_itemData? then throw new Error 'cannot delcare "recipe" before "item"'

        @_multiblockData = null
        @_recipeData = line:@_lineNumber, input:[], output:[{quantity:1, name:@_itemData.name}], tools:[]
        @_itemData.recipes ?= []
        @_itemData.recipes.push @_recipeData

    _command_tools: (toolNames...)->
        if not @_recipeData? then throw new Error 'cannot declare "tools" before "recipe"'
        if @_recipeData.tools.length isnt 0 then throw new Error 'duplicate declaration of "tools"'

        for name in toolNames
            if name.length is 0 then throw new Error 'tool names cannot be empty'
            @_recipeData.tools.push name:name, quantity:1

    _command_update: (name='')->
        if not name.length > 0 then throw new 'the item name cannot be empty'

        @_itemData   = name:name, line:@_lineNumber, type:'update'
        @_recipeData = null

        @_rawData.items ?= {}
        @_rawData.items[name] = @_itemData

    # Parsing Helpers ##############################################################################

    _parseStack: (stackText)->
        match = ModVersionParserV1.STACK.exec stackText
        if match?
            return quantity:parseInt(match[1]), name:match[2]
        else
            return quantity:1, name:stackText

    # Object Creation Methods ######################################################################

    _buildModVersion: (modVersionData, modVersion)->
        modVersionData.items ?= []

        for itemName, itemData of modVersionData.items
            @_handleErrors @_buildItem, modVersion, itemData

        modVersion.sort()
        return modVersion

    _buildItem: (modVersion, itemData)->
        @_lineNumber = itemData.line
        itemData.gatherable           ?= false
        itemData.ignoreDuringCrafting ?= false
        itemData.recipes              ?= []

        if itemData.type is 'new'
            item = new Item
                name: itemData.name,
                ignoreDuringCrafting: itemData.ignoreDuringCrafting,
                isGatherable: itemData.gatherable,
                group: itemData.group
            modVersion.addItem item
            itemData.slug = item.slug
        else
            itemData.slug = ItemSlug.slugify itemData.name
            modVersion.registerName itemData.slug, itemData.name

        if itemData.multiblockData
            item.multiblock = @_handleErrors @_buildMultiblock, modVersion, item, itemData.multiblockData

        for recipeData in itemData.recipes
            @_handleErrors @_buildRecipe, modVersion, itemData, recipeData

        return item

    _buildMultiblock: (modVersion, item, multiblockData)->
        @_lineNumber = multiblockData.line
        if multiblockData.layers.length is 0 then throw new Error '"multiblock" requires at least one "layer"'
        if multiblockData.input.length is 0 then throw new Error '"multiblock" requires at least one "input"'

        input = @_buildStackList modVersion, multiblockData.input
        multiblock = new Multiblock input:input, layers:multiblockData.layers
        return multiblock

    _buildRecipe: (modVersion, itemData, recipeData)->
        @_lineNumber = recipeData.line
        if recipeData.input.length is 0 then throw new Error 'the "input" declaration is required'
        if not recipeData.pattern? then throw new Error 'the "pattern" declaration is required'

        recipe = new Recipe
            condition:            recipeData.condition
            ignoreDuringCrafting: recipeData.ignoreDuringCrafting
            input:                @_buildStackList modVersion, recipeData.input, recipeData.pattern
            output:               @_buildStackList modVersion, recipeData.output
            pattern:              recipeData.pattern
            tools:                @_buildStackList modVersion, recipeData.tools

        modVersion.addRecipe recipe
        return recipe

    _buildStackList: (modVersion, data, pattern=null)->
        createSlug = (name)=>
            item = @_rawData.items[name]
            if item? and item.type isnt 'update'
                slug = new ItemSlug modVersion.modSlug, _.slugify name
            else
                slug = new ItemSlug name
            modVersion.registerName slug, name
            return slug

        stacks = []
        for stackData in data
            itemSlug = createSlug stackData.name
            stacks.push new Stack itemSlug:itemSlug, quantity:stackData.quantity

        if pattern?
            expectedIndexes = _.reduce [0...stacks.length], ((obj, i)-> obj[i] = true; return obj), {}
            for c in pattern
                continue if c is '.'
                continue if c is ' '
                delete expectedIndexes[c]
                if not stacks[parseInt(c)]? then throw new Error "there is no item #{c} in this recipe"

            unusedNames = _.map(_.keys(expectedIndexes), ((i)-> data[parseInt(i)].name))
            if unusedNames.length > 1
                throw new Error "#{unusedNames.join(', ')} are listed for this recipe, but do not appear in the pattern"
            else if unusedNames.length is 1
                throw new Error "#{unusedNames[0]} is listed for this recipe, but does not appear in the pattern"

        return stacks

    # Un-parsing Methods ###########################################################################

    _unparseModVersion: (builder, modVersion)->
        builder
            .line 'schema: ', 1
            .line()

        modVersion.eachGroup (group)=>
            @_unparseGroup builder, modVersion, group

        externalRecipes = modVersion.findExternalRecipes()
        keys = _.keys(externalRecipes).sort()
        for itemSlugText in keys
            recipeList = externalRecipes[itemSlugText]

            builder
                .line 'update: ', modVersion.findName ItemSlug.slugify(itemSlugText)
                .indent()
                .loop(recipeList, delimiter:'', onEach:(b, r)=> @_unparseRecipe(b, r))
                .outdent()
                .line()

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
        recipes = modVersion.findRecipes item.slug, [], onlyPrimary:true

        builder
            .line 'item: ', item.name
            .indent()
                .onlyIf item.isGatherable, => builder.line 'gatherable: yes'
                .onlyIf item.multiblock?, =>
                    builder
                        .indent()
                        .call => @_unparseMultiblock builder, item.multiblock
                        .outdent()
                .onlyIf recipes.length > 0, =>
                    builder.loop recipes, delimiter:'', onEach:(b, r)=> @_unparseRecipe(b, r)
            .outdent()

    _unparseMultiblock: (builder, multiblock)->
        builder
            .line 'multiblock:'
            .indent()
            .push "input: "
            .call => @_unparseStackList builder, multiblock.input
            .push ";\n"
            .loop(multiblock.layers, delimiter:'', onEach:(builder, layer)=> builder.line "layer: #{layer}")
            .outdent()

    _unparseRecipe: (builder, recipe)->
        inputStacks = recipe.input[..]
        inputStacks.sort (a, b)-> Stack.compare a, b
        inputNames = []
        for stack in inputStacks
            name = builder.context.findName stack.itemSlug
            if stack.quantity > 1
                inputNames.push "#{stack.quantity} #{name}"
            else
                inputNames.push name

        patternMap = {'.', '.'}
        for i in [0...recipe.input.length]
            stack = recipe.input[i]
            name = builder.context.findName(stack.itemSlug)
            name = "#{stack.quantity} #{name}" if stack.quantity > 1
            patternMap["#{i}"] = "#{inputNames.indexOf name}"

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
                .onlyIf recipe.condition?, =>
                    builder.push 'onlyIf: '
                        .onlyIf recipe.condition.inverted, -> builder.push 'not '
                        .line recipe.condition.verb, ' ', recipe.condition.noun
                .onlyIf extraOutputs.length > 0, =>
                    builder
                        .push 'extras: '
                        .call => @_unparseStackList builder, extraOutputs
                        .line()
                .onlyIf recipe.ignoreDuringCrafting, => builder.line 'ignoreDuringCrafting: yes'
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
