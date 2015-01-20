###
Crafting Guide - mod_parser_v2.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

CommandParserVersionBase = require './command_parser_version_base'
Mod                      = require '../mod'
ModVersion               = require '../mod_version'

########################################################################################################################

module.exports = class ModParserV2 extends CommandParserVersionBase

    # CommandParserVersionBase Overrides ###########################################################

    _buildModel: (rawData, model)->
        @_buildMod rawData, model

    _unparseModel: (builder, model)->
        @_unparseMod builder, model

    # Command Methods ##############################################################################

    _command_author: (authorParts...)->
        if @_rawData.author? then throw new Error 'duplicate declaration of "author"'
        author = authorParts.join ''
        if author.length is 0 then throw new Error '"author" cannot be empty, but may be omitted'

        @_rawData.author = author

    _command_description: (descriptionParts...)->
        if @_rawData.description? then throw new Error 'duplicate declaration of "description"'
        description = descriptionParts.join ', '
        if description.length is 0 then throw new Error '"description" cannot be empty, but may be omitted'

        @_rawData.description = description

    _command_name: (name)->
        if @_rawData.name? then throw new Error 'duplicate declaration of "name"'
        if name.length is 0 then throw new Error '"name" cannot be empty'
        @_rawData.name = name

    _command_url: (url='')->
        if @_rawData.url? then throw new Error 'duplicate declaration of "url"'
        if url.length is 0 then throw new Error 'url cannot be empty'

        @_rawData.url = url

    _command_version: (version='')->
        if version.length is 0 then throw new Error 'version cannot be empty'

        @_rawData.versions ?= []
        @_rawData.versions.push version

    # Object Building Methods ######################################################################

    _buildMod: (rawData, model)->
        if not rawData.name? then throw new Error 'the "name" declaration is required'
        if not rawData.url? then throw new Error 'the "url" declaration is required'
        if not rawData.versions? then throw new Error 'at least one "version" declaration is required'

        model.author      = rawData.author      if rawData.author?
        model.description = rawData.description if rawData.description?
        model.name        = rawData.name
        model.primaryUrl  = rawData.url

        for version in rawData.versions
            model.addModVersion new ModVersion modSlug:model.slug, version:version
