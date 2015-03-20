###
Crafting Guide - markdown_section_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class MarkdownSectionController extends BaseController

    constructor: (options={})->
        options.model        ?= ''
        options.title        ?= 'Description'
        options.templateName  = 'markdown_section'
        super options

        @title = options.title

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$title         = @$('h2')
        @$markdownPanel = @$('.markdown')
        super

    refresh: ->
        @$title.html @title

        @$markdownPanel.empty()
        @$markdownPanel.html _.parseMarkdown @model
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .markdown': 'routeLinkClick'
