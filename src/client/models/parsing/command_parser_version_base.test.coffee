#
# Crafting Guide - command_parser_version_base.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CommandParserVersionBase = require './command_parser_version_base'

########################################################################################################################

parser = null

########################################################################################################################

describe 'command_parser_version_base.coffee', ->

    beforeEach -> parser = new CommandParserVersionBase model:{}

    describe '_parseHereDoc', ->

        it 'returns null for non-heredoc lines', ->
            result = parser._parseHereDoc 'foobar: baz'
            expect(result[1]).to.be.null

        it 'identifies the right text for a real heredoc', ->
            parser._lines = ['command: <<-END', 'alpha', 'bravo', 'charlie', 'END', 'command1: arg2']
            parser._lineNumber = 1

            result = parser._parseHereDoc parser._lines[0]
            result[0].should.equal 'command: '
            result[1].should.equal 'alpha\nbravo\ncharlie'

        it 'identifies an empty heredoc', ->
            parser._lines = ['command: <<-END', 'END']
            parser._lineNumber = 1

            result = parser._parseHereDoc parser._lines[0]
            result[0].should.equal 'command: '
            expect(result[1]).to.be.null

        it 'trims smallest leading whitespace', ->
            parser._lines = ['command: <<-END', '  alpha', '    bravo', '', '  charlie', 'END', 'command1: arg2']
            parser._lineNumber = 1

            result = parser._parseHereDoc parser._lines[0]
            result[0].should.equal 'command: '
            result[1].should.equal 'alpha\n  bravo\n\ncharlie'
