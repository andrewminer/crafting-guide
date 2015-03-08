###
Crafting Guide - recipe_step.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class RecipeStep extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.recipe? then throw new Error 'attributes.recipe is required'
        attributes.multiple ?= 1
        super attributes, options

        @recipe.on 'change', =>
            @trigger 'change:recipe'
            @trigger 'change'

    # Public Methods ###############################################################################

    getItemAt: (index)->
        return @recipe.getItemAt index