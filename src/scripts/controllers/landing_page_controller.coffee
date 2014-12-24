###
# Crafting Guide - landing_page_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseController          = require './base_controller'
CraftingTableController = require './crafting_table_controller'
LandingPage             = require '../models/landing_page'
RecipeCatalogController = require './recipe_catalog_controller'

########################################################################################################################

module.exports = class LandingPageController extends BaseController

    constructor: (options={})->
        options.model        ?= new LandingPage
        options.templateName  = 'landing_page'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @catalogController = @addChild RecipeCatalogController, '.view__recipe_catalog', model:@model.catalog
        @tableController = @addChild CraftingTableController, '.view__crafting_table', model:@model.table
        super
