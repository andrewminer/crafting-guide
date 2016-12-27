#
# Crafting Guide - tutorial_parser_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CommandParserVersionBase = require './command_parser_version_base'
Tutorial                 = require '../site/tutorial'

########################################################################################################################

module.exports = class TutorialParserV1 extends CommandParserVersionBase

    # CommandParserVersionBase Overrides ###########################################################

    _buildModel: (rawData, model)->
        @_buildTutorial rawData, model

    _unparseModel: (builder, model)->
        @_unparseTutorial builder, model

    # Command Methods ##############################################################################

    _command_content: (contentParts...)->
        if not @_rawData.currentSection? then throw new Error 'cannot declare "title" before "section"'
        if @_rawData.currentSection.content? then throw new Error 'duplicate declaration of content'
        content = contentParts.join(', ').trim()
        if not content.length > 0 then throw new Error 'content cannot be empty'

        @_rawData.currentSection.content = content

    _command_officialUrl: (officialUrl)->
        if @_rawData.officialUrl? then throw new Error 'duplicate declaration of "officialUrl"'
        if officialUrl.length is 0 then throw new Error 'officialUrl cannot be empty'
        @_rawData.officialUrl = officialUrl

    _command_section: (textParts...)->
        @_rawData.sections ?= []
        @_rawData.sections.push @_rawData.currentSection = {}

    _command_title: (titleParts...)->
        if not @_rawData.currentSection? then throw new Error 'cannot declare "title" before "section"'
        if @_rawData.currentSection.title? then throw new Error 'duplicate declaration of title'
        title = titleParts.join(', ').trim()
        if not title.length > 0 then throw new Error 'title cannot be empty'

        @_rawData.currentSection.title = title

    _command_video: (youTubeId, nameParts...)->
        if not youTubeId?.length then throw new Error 'video declaration requires a YouTubeID'
        name = nameParts.join ', '
        if not name?.length then throw new Error 'video declaration requires a name'

        @_rawData.videos ?= []
        @_rawData.videos.push youTubeId:youTubeId, name:name

    # Object Building Methods ######################################################################

    _buildTutorial: (rawData, model)->
        if not rawData.sections? then throw new Error 'the "section" declaration is required'

        model.officialUrl = rawData.officialUrl
        model.videos      = rawData.videos
        model.sections    = rawData.sections
