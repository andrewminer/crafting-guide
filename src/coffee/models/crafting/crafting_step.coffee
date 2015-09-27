###
Crafting Guide - crafting_step.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class CraftingStep

    constructor: (recipe, repeat=0)->
        if not recipe? then throw new Error 'recipe is required'
        if repeat < 0 then throw new Error 'repeat must be at least 1'

        @_recipe = recipe
        @repeat = repeat

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        recipe:
            get: -> @_recipe

    # Object Overrides #############################################################################

    toString: ->
        return "#{@repeat}x #{@recipe.slug}"
