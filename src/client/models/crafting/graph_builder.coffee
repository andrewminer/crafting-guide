#
# Crafting Guide - graph_builder.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Inventory     = require '../game/inventory'
InventoryNode = require './inventory_node'

########################################################################################################################

module.exports = class GraphBuilder

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.want? then throw new Error 'options.want is required'

        @_maximumGraphSize = c.limits.maximumGraphSize
        @_modPack          = options.modPack
        @_stepCount        = 0
        @_want             = options.want

        @_rootNode = new InventoryNode modPack:@_modPack, inventory:@_want
        @_queue    = [@_rootNode]

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

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        complete:
            get: ->
                return true if @_stepCount > @_maximumGraphSize
                return false unless @_rootNode?
                return false unless @_queue?
                return false unless @_queue.length is 0
                return true

        rootNode:
            get: -> @_rootNode

        stepCount:
            get: -> @_stepCount

        want:
            get: -> @_want

    # Object Overrides ############################################################################

    toString: (indent='')->
        "Build Tree\n#{@_rootNode.toString(indent + '    ')}"
