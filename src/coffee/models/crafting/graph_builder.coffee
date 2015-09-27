###
Crafting Guide - graph_builder.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Inventory     = require '../inventory'
InventoryNode = require './inventory_node'

########################################################################################################################

module.exports = class GraphBuilder

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'

        @modPack = options.modPack
        @_wanted = options.wanted ?= new Inventory

        @_wanted.on 'change', => @reset()
        @reset()

    # Public Methods ###############################################################################

    expandGraph: (steps=null)->
        maxSteps = if steps? then @_stepCount + steps else Number.MAX_VALUE
        @_queue ?= []

        while true
            break if @_queue.length is 0
            break if @_stepCount >= maxSteps

            node = @_queue.shift()
            break unless node?

            node.expand @_queue
            @_stepCount += 1

    reset: ->
        @_rootNode = new InventoryNode modPack:@modPack, inventory:@wanted
        @_queue = [@_rootNode]
        @_stepCount = 0

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        complete:
            get: ->
                return false unless @_rootNode?
                return false unless @_queue?
                return false unless @_queue.length is 0
                return true

        rootNode:
            get: -> @_rootNode

        stepCount:
            get: -> @_stepCount

        wanted:
            get: -> @_wanted

    # Object Overrides ############################################################################

    toString: (indent='')->
        "Build Tree\n#{@_rootNode.toString(indent + '    ')}"
