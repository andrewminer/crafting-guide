###
# Crafting Guide - recipe_catalog_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class RecipeCatalogController extends BaseController

    constructor: (options={})->
        options.templateName = 'recipe_catalog'
        super options
