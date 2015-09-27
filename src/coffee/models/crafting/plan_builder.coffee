###
Crafting Plan - plan_builder.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

CraftingNode = require './crafting_node'
CraftingPlan = require './crafting_plan'
CraftingStep = require './crafting_step'
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

        while not @complete and (@plans.length < maxPlans)
            plan = @_captureCurrentPlan()
            if plan?
                @plans.push plan

            @_incrementChoiceNodes()

        return @_plans

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        complete:
            get: -> @_complete

        plans:
            get: -> @_plans

        wanted:
            get: -> @_wanted
            set: (wanted)-> @_wanted = wanted or new Inventory

    # Private Methods ##############################################################################

    _captureCurrentPlan: ->
        toVisit = [@_rootNode]
        stepNodes = []

        while toVisit.length > 0
            node = toVisit.shift()

            if node.TYPE is CraftingNode::TYPES.INVENTORY
                toVisit.push(c) for c in node.children
            else if node.TYPE is CraftingNode::TYPES.ITEM
                toVisit.push node.children[0] if node.children.length > 0
            else if node.TYPE is CraftingNode::TYPES.RECIPE
                stepNodes.push node
                toVisit.push(c) for c in node.children

        steps = []
        seenRecipes = {}
        index = stepNodes.length - 1
        while index >= 0
            node = stepNodes[index]
            index -= 1
            return null unless node.valid and node.complete

            recipeSlug = node.recipe.slug
            continue if seenRecipes[recipeSlug]?

            seenRecipes[recipeSlug] = true
            steps.push new CraftingStep node.recipe

        plan = new CraftingPlan steps, @_wanted
        return plan

    _incrementChoiceNodes: ->
        if @_choiceNodes.length is 0
            @_complete = true
            return

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
