###
Crafting Plan - plan_builder.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

CraftingNode = require './crafting_node'
CraftingPlan = require './crafting_plan'
Inventory    = require '../inventory'

########################################################################################################################

module.exports = class PlanBuilder

    constructor: (rootNode, options={})->
        if not rootNode? then throw new Error 'rootNode is required'

        @wanted = options.wanted

        @_choiceNodes = []
        @_complete    = false
        @_plans       = []
        @_rootNode    = rootNode

        @_isolateChoiceNodes()

    # Public Methods ###############################################################################

    producePlans: (maxPlans=null)->
        maxPlans = if maxPlans then @plans.length + maxPlans else Number.MAX_VALUE

        while @plans.length is 0 or (@plans.length < maxPlans and not @complete)
            plan = @_captureCurrentPlan()
            @plans.push plan
            @_incrementChoiceNodes()

        return @_plans

    # Property Methods #############################################################################

    isComplete: ->
        return @_complete

    getPlans: ->
        return @_plans

    getWanted: ->
        return @_wanted

    setWanted: (wanted)->
        @_wanted = wanted or new Inventory

    Object.defineProperties @prototype,
        complete: { get:@prototype.isComplete }
        plans:    { get:@prototype.getPlans }
        wanted:   { get:@prototype.getWanted, set:@prototype.setWanted }

    # Private Methods ##############################################################################

    _captureCurrentPlan: ->
        toVisit = [@_rootNode]
        steps = []

        while toVisit.length > 0
            node = toVisit.shift()

            if node.TYPE is CraftingNode::TYPES.INVENTORY
                toVisit.push(c) for c in node.children
            else if node.TYPE is CraftingNode::TYPES.ITEM
                toVisit.push node.children[0] if node.children.length > 0
            else if node.TYPE is CraftingNode::TYPES.RECIPE
                steps.push node.recipe
                toVisit.push(c) for c in node.children

        steps.reverse()
        plan = new CraftingPlan steps, @_wanted
        return plan

    _incrementChoiceNodes: ->
        index = @_choiceNodes.length - 1
        while true
            if index is -1
                @_complete = true
                return

            node = @_choiceNodes[index]
            node.rotateChildren()

            return unless node.rotations % node.children.length is 0
            index -= 1

    _isolateChoiceNodes: ->
        @_rootNode.acceptVisitor
            onEnterItemNode: (node)=>
                if node.children.length > 1
                    @_choiceNodes.push node
