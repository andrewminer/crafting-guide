###
Crafting Guide - markdown_section_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class MarkdownSectionController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.model        ?= ''
        options.title        ?= 'Description'
        options.templateName  = 'markdown_section'
        super options

        @modPack = options.modPack
        @title   = options.title

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$title         = @$('h2')
        @$markdownPanel = @$('.markdown')
        super

    refresh: ->
        @$title.html @title

        @$markdownPanel.empty()
        @$markdownPanel.html @_parseMarkdown()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .markdown a': 'routeLinkClick'

    # Private Methods ##############################################################################

    _parseMarkdown: ->
        return '' unless @model

        tree = markdown.parse @model, 'Maruku'

        findLinkRefs = (node)=>
            logger.verbose "inspecting a #{node[0]}"
            if node[0] is 'link_ref'
                logger.verbose "looking for item named: #{node[2]}"
                item = @modPack.findItemByName node[2]
                if item?
                    logger.verbose "found item #{item.slug}, updating link"
                    node[0] = 'link'
                    node[1].href = Url.item itemSlug:item.slug.item, modSlug:item.slug.mod
                    delete node[1].ref
            else
                for index in [1...node.length]
                    if _.isArray node[index]
                            logger.indent()
                            findLinkRefs node[index]
                            logger.outdent()

        logger.verbose "replacing wiki-style links"
        findLinkRefs tree
        logger.verbose "finished"

        html = markdown.renderJsonML markdown.toHTMLTree tree
        return html
