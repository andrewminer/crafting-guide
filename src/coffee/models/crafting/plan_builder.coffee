###
Crafting Plan - plan_builder.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

CraftingNode = require './crafting_node'

########################################################################################################################

module.exports = class PlanBuilder

    constructor: (rootNode)->
        if not rootNode? then throw new Error 'rootNode is required'

        @_choiceNodes = []
        @_complete    = false
        @_plans       = []
        @_rootNode    = rootNode

        @_isolateChoiceNodes()

    # Public Methods ###############################################################################

    producePlans: (maxPlans=null)->
        maxPlans = if maxPlans then @plans.length + maxPlans else Number.MAX_VALUE

        while @plans.length < maxPlans and not @complete
            plan = @_captureCurrentPlan()
            @plans.push plan if plan.length > 0
            @_incrementChoiceNodes()

        return @_plans

    # Property Methods #############################################################################

    isComplete: ->
        return @_complete

    getPlans: ->
        return @_plans

    Object.defineProperties @prototype,
        complete: { get:@prototype.isComplete }
        plans: { get:@prototype.getPlans }

    # Private Methods ##############################################################################

    _captureCurrentPlan: ->
        toVisit = [@_rootNode]
        plan = []

        while toVisit.length > 0
            node = toVisit.shift()

            if node.TYPE is CraftingNode::TYPES.INVENTORY
                toVisit.push(c) for c in node.children
            else if node.TYPE is CraftingNode::TYPES.ITEM
                toVisit.push node.children[0] if node.children.length > 0
            else if node.TYPE is CraftingNode::TYPES.RECIPE
                plan.push node.recipe
                toVisit.push(c) for c in node.children

        return plan.reverse()

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
