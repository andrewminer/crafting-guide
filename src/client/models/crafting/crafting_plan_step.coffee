#
# Crafting Guide - crafting_plan_step.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class CraftingPlanStep

    constructor: (recipe, count=1)->
        @_id    = _.uniqueId "crafting-plan-step-"
        @recipe = recipe
        @count  = count

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        recipe:
            get: -> return @_recipe
            set: (recipe)->
                if not recipe? then throw new Error 'recipe is required'
                if @_recipe is recipe then return
                if @_recipe? then throw new Error 'recipe cannot be reassigned'
                @_recipe = recipe

        count:
            get: -> return @_count
            set: (count)->
                count = parseInt "#{count}"
                count = if Number.isNaN(count) then 0 else Math.max 0, count
                @_count = count

    # Object Overrides #############################################################################

    toString: ->
        return "CraftingPlanStep:#{@_recipe}×#{@_count}<#{@_id}>"
