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

    # Event Methods ################################################################################

    onEnabledChanged: ->
        return unless @rendered

        @model.enabled = @$(':checked').length > 0

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$enabled     = @$('td:nth-child(1) input')
        @$name        = @$('td:nth-child(2) p')
        @$description = @$('td:nth-child(3) p')
        super

    refresh: ->
        if @model.enabled then @$enabled.attr('checked', 'checked') else @$enabled.removeAttr('checked')
        @$name.html "#{@model.modName} (#{@model.modVersion})"
        @$description.html "#{@model.description}"

    # Backbone.View Overrides ######################################################################

    events:
        'change input[type="checkbox"]': 'onEnabledChanged'
