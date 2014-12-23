###
# Crafting Guide - landing_page.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel = require './base_model'
RecipeCatalog = require './recipe_catalog'

########################################################################################################################

module.exports = class LandingPage extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.catalog ?= new RecipeCatalog
        super attributes, options
