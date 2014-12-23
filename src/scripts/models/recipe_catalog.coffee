###
# Crafting Guide - recipe_catalog.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel        = require './base_model'
{Event}         = require '../constants'
RecipeBookParser = require './recipe_book_parser'

########################################################################################################################

module.exports = class RecipeCatalog extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.books ?= []
        super attributes, options

        @_parser = new RecipeBookParser

    # Public Methods ###############################################################################

    loadBook: (url)->
        @trigger Event.book.load.started, this, url
        $.ajax
            url: url
            dataType: 'json'
            success: (data, status, xhr)=> @onBookLoaded(data, status, xhr)
            error: (xhr, status, error)=> @onBookLoadFailed(error, status, xhr)

    # Event Methods ################################################################################

    onBookLoaded: (data, status, xhr)->
        try
            @books.push @_parser.parse data
            _(@books).sortBy 'name'

            logger.info "loaded recipe book: #{book}"
            @trigger Event.book.load.succeeded, this, book
            @trigger Event.book.load.finished, this
        catch e
            @onBookLoadFailed error, status, xhr


    onBookLoadFailed: (error, status, xhr)->
        logger.error "failed to load recipe book: #{error}"
        @trigger Event.book.load.failed, this, error.message
        @trigger Event.book.load.finished, this

    # Object Overrides #############################################################################

    toString: ->
        return "RecipeCatalog (#{@cid}) {books:#{@books.length} items}"
