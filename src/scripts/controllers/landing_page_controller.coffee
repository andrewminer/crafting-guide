###
# Crafting Guide - crafting_guide_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseController          = require './base_controller'
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
        @recipeBooksController = @addChild RecipeCatalogController, '.view__recipe_catalog'
        super
