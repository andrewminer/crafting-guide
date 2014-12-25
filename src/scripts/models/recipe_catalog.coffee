###
# Crafting Guide - recipe_catalog.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel         = require './base_model'
{Event}           = require '../constants'
RecipeBookParser  = require './recipe_book_parser'

########################################################################################################################

module.exports = class RecipeCatalog extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.books ?= []
        super attributes, options

        @_parser = new RecipeBookParser

    # Public Methods ###############################################################################

    findRecipes: (name)->
        result = []
        for book in @books
            for recipe in book.findRecipes name
                result.push recipe

        return result

    loadBook: (url)->
        w.promise (resolve, reject)=>
            @trigger Event.load.started, this, url
            $.ajax
                url: url
                dataType: 'json'
                success: (data, status, xhr)=>
                    resolve @onBookLoaded(url, data, status, xhr)
                error: (xhr, status, error)=>
                    reject @onBookLoadFailed(url, error, status, xhr)

    loadBookData: (data)->
        book = @_parser.parse data
        @books.push book
        @books.sort (a, b)->
            return 0 if a.modName is b.modName
            return if a.modName < b.modName then -1 else +1

        return book

    loadAllBooks: (urlList)->
        promises = (@loadBook(url) for url in urlList)
        return w.settle promises

    # Event Methods ################################################################################

    onBookLoaded: (url, data, status, xhr)->
        try
            book = @loadBookData data

            logger.info "loaded recipe book from #{url}: #{book}"
            @trigger Event.load.succeeded, this, book
            @trigger Event.load.finished, this
            @trigger Event.change, this

            return book
        catch e
            @onBookLoadFailed url, e, status, xhr

    onBookLoadFailed: (url, error, status, xhr)->
        message = if error.stack? then error.stack else error
        logger.error "failed to load recipe book from #{url}: #{message}"
        @trigger Event.load.failed, this, error.message
        @trigger Event.load.finished, this
        return error

    # Object Overrides #############################################################################

    toString: ->
        return "RecipeCatalog (#{@cid}) {books:#{@books.length} items}"
