###
Crafting Guide - item_parser_v1.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

CommandParserVersionBase = require './command_parser_version_base'

########################################################################################################################

module.exports = class ItemParserV1 extends CommandParserVersionBase

    # CommandParserVersionBase Overrides ###########################################################

    _buildModel: (rawData, model)->
        @_buildItem rawData, model

    _unparseModel: (builder, model)->
        @_unparseItem builder, model

    # Command Methods ##############################################################################

    _command_description: (textParts...)->
        @_rawData.description ?= ''
        @_rawData.description += textParts.join ', '

    _command_officialUrl: (officialUrl)->
        if @_rawData.officialUrl? then throw new Error 'duplicate declaration of "officialUrl"'
        if officialUrl.length is 0 then throw new Error 'officialUrl cannot be empty'
        @_rawData.officialUrl = officialUrl

    _command_video: (youTubeId, nameParts...)->
        if not youTubeId?.length then throw new Error 'video declaration requires a YouTubeID'
        name = nameParts.join ', '
        if not name?.length then throw new Error 'video declaration requires a name'

        @_rawData.videos ?= []
        @_rawData.videos.push youTubeId:youTubeId, name:name

    # Object Building Methods ######################################################################

    _buildItem: (rawData, model)->
        model.description = rawData.description if rawData.description
        model.officialUrl = rawData.officialUrl if rawData.officialUrl
        model.videos      = rawData.videos      if rawData.videos
