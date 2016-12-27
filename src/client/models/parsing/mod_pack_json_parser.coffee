#
# Crafting Guide - mod_pack_json_parser.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Item    = require "../game/item"
Mod     = require "../game/mod"
ModPack = require "../game/mod_pack"
Recipe  = require "../game/recipe"
Stack   = require "../game/stack"

########################################################################################################################

module.exports = class ModPackJsonParser

    constructor: ->
        @_reset()

    # Public Methods ###############################################################################

    parse: (arg, fileName=null)->
        @_reset()
        @_fileName = fileName

        if _.isString arg
            @_parseText arg
        else
            @_parseObject arg

        return @_modPack

    # Private Methods ##############################################################################

    _parseInteger: (text, defaultValue)->
        result = parseInt "#{text}"
        result = if Number.isNaN result then defaultValue else result
        return result

    _parseText: (text)->
        try
            obj = JSON.parse text
        catch error
            @_throwError "could not parse JSON: #{error}"

        @_parseObject obj

    _parseObject: (obj)->
        @_data = obj
        @_parseModPack()
        @_parseMods()
        @_parseItems()
        @_parseRecipes()

    _parseModPack: ->
        if not @_data? then @_throwError "there is no valid data"
        if not @_data.id? then @_throwError "modPack requires an id"
        if not @_data.displayName? then @_throwError "modPack requires a displayName"

        @_modPack = new ModPack id:@_data.id, displayName:@_data.displayName

    _parseMods: ->
        return unless @_data.mods?

        for modData, index in @_data.mods
            @_location = "mods[#{index}]"
            if not modData.id? then @_throwError "mod requires an id"
            if not modData.displayName? then @_throwError "mod requires a displayName"

            new Mod modPack:@_modPack, id:modData.id, displayName:modData.displayName

    _parseItems: ->
        return unless @_data.mods?

        for modData in @_data.mods
            continue unless modData.items?

            mod = @_modPack.mods[modData.id]
            for itemData, index in modData.items
                @_location = "<#{mod.id}>.items[#{index}]"
                if not itemData.id? then @_throwError "item requires an id"
                if not itemData.displayName? then @_throwError "item requires a displayName"

                item = new Item mod:mod, id:itemData.id, displayName:itemData.displayName
                item.gatherable = itemData.gatherable if itemData.gatherable?
                @_items.push item

    _parseRecipes: ->
        return unless @_data.mods?

        for modData in @_data.mods
            continue unless modData.items?

            mod = @_modPack.mods[modData.id]
            for itemData, index in modData.items
                continue unless itemData.recipes?

                item = mod.items[itemData.id]
                for recipeData, index in itemData.recipes
                    @_location = "<#{itemData.id}>.recipes[#{index}]"
                    if not recipeData.id? then @_throwError "recipe requires id"
                    if not recipeData.inputs? then @_throwError "recipe requires inputs"

                    quantity = @_parseInteger recipeData.quantity, 1
                    outputStack = new Stack item:item, quantity:quantity
                    recipe = new Recipe id:recipeData.id, output:outputStack

                    depth = @_parseInteger recipeData.depth, 1
                    height = @_parseInteger recipeData.height, 3
                    width = @_parseInteger recipeData.width, 3

                    index = 0
                    for x in [0...width]
                        for y in [0...height]
                            for z in [0...depth]
                                stack = @_parseStack recipeData.inputs[index]
                                if stack? then recipe.setInputAt x, y, z, stack
                                index++

                    if recipeData.extras
                        for stackData in recipeData.extras
                            recipe.addExtra @_parseStack stackData

                    if recipeData.tools
                        for index in recipeData.tools
                            toolItem = @_items[index]
                            if not toolItem? then @_throwError "there is no item #{index}"
                            recipe.addTool toolItem

    _parseStack: (stackData)->
        return null unless stackData?
        if _.isArray(stackData)
            if stackData.length isnt 2 then @_throwError "input stacks must have an item index and a quantity"
            index = stackData[0]
            quantity = stackData[1]
        else
            index = stackData
            quantity = 1

        item = @_items[index]
        if not item? then @_throwError "there is no item #{index}"

        return new Stack item:item, quantity:quantity

    _reset: ->
        @_data = null
        @_fileName = null
        @_items = []
        @_location = null
        @_modPack = null

    _throwError: (message, cause=null)->
        if @_location? then message = "#{@_location}: #{message}"
        if @_fileName? and @_location? then message = "@#{message}"
        if @_fileName? then message = "#{@_fileName}#{message}"
        if cause? then message = "#{message}: #{cause}"

        error = new Error message
        error.cause = cause if cause?
        error.fileName = @_fileName if @_fileName?
        error.location = @_location if @_location?

        throw error
