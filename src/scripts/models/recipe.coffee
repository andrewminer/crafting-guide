###
# Crafting Guide - recipe.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Recipe extends BaseModel

    constructor: (attributes={}, options={})->
        super attributes, options

        Object.defineProperty this, 'name', get:-> @output[0].name
