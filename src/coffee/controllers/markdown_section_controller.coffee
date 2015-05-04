###
Crafting Guide - markdown_section_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController  = require './base_controller'
convertMarkdown = require 'marked'
_               = require 'underscore'
{Url}           = require '../constants'

########################################################################################################################

module.exports = class MarkdownSectionController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.imageBase    ?= ''
        options.model        ?= ''
        options.title        ?= 'Description'
        options.templateName  = 'markdown_section'
        super options

        @imageBase = options.imageBase
        @modPack   = options.modPack
        @title     = options.title

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$title         = @$('h2')
        @$markdownPanel = @$('.markdown')

        super

    refresh: ->
        @$title.html @title

        text = @model
        text = @_convertWikiLinks text
        text = @_convertImageLinks text

        @$markdownPanel.html convertMarkdown text

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .markdown a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _convertImageLinks: (text)->
        text.replace /\!\[([^\]]*)\]\(([^\)]*)\)/g, (match, altText, fileName)=>
            return "![#{altText}](#{@imageBase}/#{fileName})"

    _convertWikiLinks: (text)->
        text.replace /\[\[([^\]]*)\]\]/g, (match, name)=>
            result = match
            item = @modPack.findItemByName name
            if item?
                display = @modPack.findItemDisplay item.slug
                result = "[#{name}](#{display.itemUrl})"

            return result
