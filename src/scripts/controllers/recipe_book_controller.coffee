###
# Crafting Guide - recipe_book_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class RecipeBookController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error "options.model is required"
        options.templateName = 'recipe_book'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$name = @$('td:nth-child(1) p')
        @$description = @$('td:nth-child(2) p')
        super

    refresh: ->
        @$name.html "#{@model.modName} (#{@model.modVersion})"
        @$description.html "#{@model.description}"
