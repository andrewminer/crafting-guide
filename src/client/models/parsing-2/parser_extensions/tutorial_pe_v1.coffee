#
# Crafting Guide - tutorial_pe_v1.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ParserExtension = require '../parser_extension'

########################################################################################################################

module.exports = class TutorialParserExtensionV1 extends ParserExtension

    constructor: (data)->
        super data, 'tutorial',
            content:  @_command_content
            section:  @_command_section
            title:    @_command_title
            tutorial: @_command_tutorial

    # Command Methods ##############################################################################

    _command_content: (command)->
        return if @missingCurrent command, 'tutorial'
        return if @missingArgText command

        section = @data.getCurrent 'section'
        section.content = command.argText

    _command_section: (command)->
        return if @missingCurrent command, 'tutorial'

        section = @data.create command, 'section'
        section.tutorial = @data.getCurrent 'tutorial'

    _command_title: (command)->
        return if @missingCurrent command, 'section'
        return if @missingArgText command

        section = @data.getCurrent 'section'
        return if @duplicateField command, section, 'title'

        section.title = command.argText

    _command_tutorial: (command)->
        return if @missingCurrent command, 'modVersion'
        return if @missingArgText command

        tutorial = @data.create command, 'tutorial', command.argText
        tutorial.name = command.argText
        tutorial.modVersion = @data.getCurrent 'modVersion'
