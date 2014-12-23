###
# Crafting Guide - recipe_book_parser.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

V1 = require './parser_versions/v1'

########################################################################################################################

module.exports = class RecipeBookParser

    constructor: ->
        @_parsers =
            '1': new V1

    parse: (data)->
        if not data? then throw new Error 'recipe book data is missing'
        if not data.version? then throw new Error 'version is required'

        parser = @_parsers["#{data.version}"]
        if not parser?
            throw new Error "cannot parse version #{data.version} recipe books"

        return parser.parse data
