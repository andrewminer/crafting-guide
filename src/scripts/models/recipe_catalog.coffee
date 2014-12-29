###
# Crafting Guide - recipe_catalog.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel        = require './base_model'
{Event}          = require '../constants'
RecipeBookParser = require './recipe_book_parser'
{RequiredMods}   = require '../constants'

########################################################################################################################

module.exports = class RecipeCatalog extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.books ?= []
        super attributes, options

        @_parser = new RecipeBookParser

    # Public Methods ###############################################################################

    enableBooksForRecipe: (name)->
        for book in @books
            continue if book.enabled
            if book.hasRecipe name
                book.enabled = true

    gatherNames: ->
        nameData = {}
        for book in @books
            continue unless book.enabled
            book.gatherNames nameData

        result = []
        names = _.keys(nameData).sort()
        for name in names
            result.push nameData[name]
        return result

    gatherRecipes: (name)->
        result = []
        for book in @books
            book.gatherRecipes name, result

        return result

    hasRecipe: (name)->
        for book in @books
            return true if book.hasRecipe(name)
        return false

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
        @_sortBooks()
        book.on Event.change, => @trigger Event.change, this

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

    _sortBooks:->
        @books.sort (a, b)->
            if a.modName is b.modName then return 0

            aRequired = a.modName in RequiredMods
            bRequired = b.modName in RequiredMods

            if aRequired and bRequired
                return if a.modName < b.modName then -1 else +1
            else if aRequired
                return -1
            else if bRequired
                return +1
            else
                return if a.modName < b.modName then -1 else +1
