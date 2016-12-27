#
# Crafting Guide - item_parser_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CommandParserVersionBase = require './command_parser_version_base'

########################################################################################################################

module.exports = class ItemParserV1 extends CommandParserVersionBase

    # CommandParserVersionBase Overrides ###########################################################

    _buildModel: (rawData, model)->
        @_buildItem rawData, model

    _unparseModel: (builder, model)->
        builder.line 'schema: ', 1
        builder.line()

        @_unparseItem builder, model

    # Command Methods ##############################################################################

    _command_description: (textParts...)->
        if not @_rawData.description?
            @_rawData.description = ''
        else
            @_rawData.description += '\n'
        @_rawData.description += textParts.join ', '

    _command_officialUrl: (officialUrl)->
        if @_rawData.officialUrl? then throw new Error 'duplicate declaration of "officialUrl"'
        if not officialUrl? or (officialUrl.length is 0) then throw new Error 'officialUrl cannot be empty'
        @_rawData.officialUrl = officialUrl

    _command_video: (youTubeId, nameParts...)->
        if not youTubeId?.length then throw new Error 'video declaration requires a YouTubeID'
        name = nameParts.join ', '
        if not name?.length then throw new Error 'video declaration requires a name'

        @_rawData.videos ?= []
        @_rawData.videos.push youTubeId:youTubeId, name:name

    # Object Building Methods ######################################################################

    _buildItem: (rawData, model)->
        model.description = rawData.description if rawData.description?
        model.officialUrl = rawData.officialUrl if rawData.officialUrl?
        model.videos      = rawData.videos      if rawData.videos?

    # Un-parsing Methods ###########################################################################

    _unparseItem: (builder, model)->
        if model.officialUrl?
            builder.line 'officialUrl: ', model.officialUrl
            builder.line()

        if model.description?
            if model.description.indexOf('\n') isnt -1
                builder.line 'description: <<-END'
                builder.line model.description
                builder.line 'END'
            else
                builder.line 'description: ', model.description
        builder.line()

        for video in model.videos
            builder.line 'video: ', video.youTubeId, ', ', video.name
        builder.line()
