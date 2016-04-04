#
# Crafting Guide - plan_builder.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingNode = require './crafting_node'
CraftingPlan = require './crafting_plan'
CraftingStep = require './crafting_step'
Inventory    = require '../game/inventory'

########################################################################################################################

module.exports = class PlanBuilder

    constructor: (rootNode, modPack, options={})->
        if not rootNode? then throw new Error 'rootNode is required'
        if not modPack? then throw new Error 'modPack is required'

        @want = options.want
        @have = options.have

        @_choiceNodes  = []
        @_complete     = false
        @_maxPlanCount = c.limits.maximumPlanCount
        @_modPack      = modPack
        @_plans        = []
        @_rootNode     = rootNode

        @_isolateChoiceNodes()

    # Public Methods ###############################################################################

    producePlans: (maxPlans=null)->
        maxPlans = if maxPlans then @plans.length + maxPlans else Number.MAX_VALUE

        if @plans.length >= @_maxPlanCount
            @_complete = true

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

        have:
            get: -> @_have
            set: (have)-> @_have = have or new Inventory

        maxPlanCount:
            get: -> @_maxPlanCount
            set: (value)-> @_maxPlanCount = value

        plans:
            get: -> @_plans

        want:
            get: -> @_want
            set: (want)-> @_want = want or new Inventory

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
            steps.push new CraftingStep node.recipe, @_modPack

        plan = new CraftingPlan @_modPack, @_want, @_have, steps
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
