#
# Crafting Guide - recipe.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

{StringBuilder} = require 'crafting-guide-common'

########################################################################################################################

module.exports = class Recipe

    constructor: (attributes={})->
        @depth  = attributes.depth
        @height = attributes.height
        @id     = attributes.id
        @output = attributes.output
        @width  = attributes.width

        @_extras    = {}
        @_inputs    = {}
        @_inputGrid = []
        @_tools     = {}

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        allProducts: # an array of Stacks starting the the primary output of this recipe
            get: -> return [].concat @output, (stack for id, stack of @extras)
            set: -> throw new Error "allProducts cannot be assigned"

        depth: # an integer specifying the number of layers to this recipe
            get: -> return @_depth
            set: (depth)->
                depth = parseInt "#{depth}"
                depth = if Number.isNaN(depth) then 0 else Math.max(0, depth)
                @_depth = depth

        extras: # a hash of item id to Stack of all the non-primary outputs of this recipe
            get: -> return @_extras
            set: -> throw new Error "extras cannot be replaced"

        id: # a string which uniquely identifies this recipe
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                if @_id is id then return
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        height: # an integer specifying the number of rows needed by this recipe
            get: -> return @_height
            set: (height)->
                height = parseInt "#{height}"
                height = if Number.isNaN(height) then 0 else Math.max(0, height)
                @_height = height

        inputs: # a hash of item id to Item containing all the inputs to this recipe
            get: -> return @_inputs
            set: -> throw new Error "inputs cannot be replaced"

        needsTools: # a boolean indicating whether this recipe requires a tool
            get: -> return (id for id, toolItem of @_tools).length > 0

        output: # a Stack specifying the primary output of this recipe
            get: -> return @_output
            set: (output)->
                if not output? then throw new Error "output is required"
                if @_output is output then return
                if @_output? then throw new Error "output cannot be reassigned"
                @_output = output
                @_output.item.addRecipe this

        modPack: # the ModPack to which this recipe belongs
            get: -> return @_output.modPack
            set: -> throw new Error "modPack cannot be replaced"

        tools: # a hash of item id to Item of all the tools required for this recipe
            get: -> return @_tools
            set: -> throw new Error "tools cannot be assigned"

        width: # an integer specifying the number of columns needed by this recipe
            get: -> return @_width
            set: (width)->
                width = parseInt "#{width}"
                width = if Number.isNaN(width) then 0 else Math.max(0, width)
                @_width = width

    # Public Methods ###############################################################################

    addExtra: (stack)->
        return unless stack
        return if @_extras[stack.item.id] is stack
        @_extras[stack.item.id] = stack
        stack.item.addRecipe this

    addTool: (item)->
        return unless item
        @_tools[item.id] = item

    computeQuantityRequired: (item)->
        result = 0

        for x in [0...@width]
            for y in [0...@height]
                for z in [0...@depth]
                    stack = @getInputAt x, y, z
                    continue unless stack?
                    continue unless stack.item.id is item.id
                    result += stack.quantity

        return result

    computeQuantityProduced: (item)->
        result = 0

        if @_output.item.id is item.id
            result += @_output.quantity

        for itemId, stack of @_extras
            continue unless itemId is item.id
            result += stack.quantity

        return result

    getInputAt: ->
        [x, y, z] = [0, 0, 0]
        if arguments.length is 3
            [x, y, z] = arguments
        else
            [x, y] = arguments

        return @_inputGrid[x]?[y]?[z] or null

    setInputAt: ->
        [x, y, z, stack] = [0, 0, 0, null]
        if arguments.length is 4
            [x, y, z, stack] = arguments
        else
            [x, y, stack] = arguments

        @_depth = Math.max @_depth, z + 1
        @_height = Math.max @_height, y + 1
        @_width = Math.max @_width, x + 1

        @_inputGrid[x] ?= []
        @_inputGrid[x][y] ?= []
        @_inputGrid[x][y][z] = stack

        if stack?.item? then @_inputs[stack.item.id] = stack.item

    # Object Overrides #############################################################################

    toString: (options={})->
        options.full ?= false

        if options.full
            b = new StringBuilder
            b.loop (item for id, item of @inputs), delimiter:" + ", onEach:(b, item)=>
                b.push @computeQuantityRequired(item), " ", item.displayName
            b.push " ="
            b.onlyIf @needsTools, (b)=>
                b.push "("
                b.loop (toolItem for id, toolItem of @tools), onEach:(b, toolItem)-> b.push toolItem.displayName
                b.push ")"
            b.push "=> "
            b.loop @allProducts, delimiter:" + ", onEach:(b, stack)=>
                b.push stack.quantity, " ", stack.item.displayName

            return b.toString()
        else
            return "Recipe:#{@output}<#{@id}>"
