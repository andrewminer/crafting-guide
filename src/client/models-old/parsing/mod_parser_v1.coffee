#
# Crafting Guide - mod_parser_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CommandParserVersionBase = require './command_parser_version_base'
Mod                      = require '../game/mod'
ModVersion               = require '../game/mod_version'
Tutorial                 = require '../site/tutorial'

########################################################################################################################

module.exports = class ModParserV1 extends CommandParserVersionBase

    # CommandParserVersionBase Overrides ###########################################################

    _buildModel: (rawData, model)->
        @_buildMod rawData, model

    _unparseModel: (builder, model)->
        @_unparseMod builder, model

    # Command Methods ##############################################################################

    _command_author: (authorParts...)->
        if @_rawData.author? then throw new Error 'duplicate declaration of "author"'
        author = authorParts.join ', '
        if author.length is 0 then throw new Error '"author" cannot be empty, but may be omitted'

        @_rawData.author = author

    _command_description: (descriptionParts...)->
        if @_rawData.description? then throw new Error 'duplicate declaration of "description"'
        description = descriptionParts.join ', '
        if description.length is 0 then throw new Error '"description" cannot be empty, but may be omitted'

        @_rawData.description = description

    _command_documentationUrl: (documentationUrl)->
        documentationUrl ?= ''
        if @_rawData.documentationUrl? then throw new Error 'duplicate declaration of "documentationUrl"'
        if documentationUrl.length is 0 then throw new Error 'documentationUrl cannot be empty (omit it instead)'
        @_rawData.documentationUrl = documentationUrl

    _command_downloadUrl: (downloadUrl)->
        if @_rawData.downloadUrl? then throw new Error 'duplicate declaration of "downloadUrl"'
        if downloadUrl.length is 0 then throw new Error 'downloadUrl cannot be empty (omit it instead)'
        @_rawData.downloadUrl = downloadUrl

    _command_homePageUrl: (homePageUrl='')->
        if @_rawData.homePageUrl? then throw new Error 'duplicate declaration of "homePageUrl"'
        if homePageUrl.length is 0 then throw new Error 'homePageUrl cannot be empty'

        @_rawData.homePageUrl = homePageUrl

    _command_name: (name)->
        if @_rawData.name? then throw new Error 'duplicate declaration of "name"'
        if name.length is 0 then throw new Error '"name" cannot be empty'
        @_rawData.name = name

    _command_tutorial: (nameParts...)->
        name = nameParts.join(', ').trim()
        if name.length is 0 then throw new Error '"name" cannot be empty'
        @_rawData.tutorialNames ?= []
        @_rawData.tutorialNames.push name

    _command_version: (version='')->
        if version.length is 0 then throw new Error 'version cannot be empty'

        @_rawData.versions ?= []
        @_rawData.versions.push version

    # Object Building Methods ######################################################################

    _buildMod: (rawData, model)->
        if not rawData.name? then throw new Error 'the "name" declaration is required'
        if not rawData.homePageUrl? then throw new Error 'the "homePageUrl" declaration is required'
        if not rawData.versions? then throw new Error 'at least one "version" declaration is required'

        model.author           = rawData.author           if rawData.author?
        model.description      = rawData.description      if rawData.description?
        model.documentationUrl = rawData.documentationUrl if rawData.documentationUrl?
        model.downloadUrl      = rawData.downloadUrl      if rawData.downloadUrl?
        model.name             = rawData.name
        model.homePageUrl      = rawData.homePageUrl

        if rawData.tutorialNames?
            for tutorialName in rawData.tutorialNames
                model.addTutorial new Tutorial name:tutorialName

        for version in rawData.versions
            model.addModVersion new ModVersion modSlug:model.slug, version:version
