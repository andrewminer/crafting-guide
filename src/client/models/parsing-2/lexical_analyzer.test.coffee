#
# Crafting Guide - lexical_analyzer.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

LexicalAnalyzer = require './lexical_analyzer'

########################################################################################################################

lexer = null

createLexer = (text)->
    return new LexicalAnalyzer 'file.cg', text

########################################################################################################################

describe 'lexical_analyzer.coffee', ->

    describe 'a document with', ->

        it 'no content returns null immediately', ->
            lexer = createLexer ''
            expect(lexer.next()).to.be.null

        it 'only whitespace returns null immediately', ->
            lexer = createLexer '\n\n       \n      \n\n'
            expect(lexer.next()).to.be.null

        it 'a single command returns only that command', ->
            lexer = createLexer 'alpha: bravo'
            lexer.next().name.should.equal 'alpha'
            expect(lexer.next()).to.be.null

        it 'multiple commands on a single line returns all commands', ->
            lexer = createLexer 'alpha: bravo; charlie: delta; echo: foxtrot'
            lexer.next().name.should.equal 'alpha'
            lexer.next().name.should.equal 'charlie'
            lexer.next().name.should.equal 'echo'
            expect(lexer.next()).to.be.null

        it 'multiple commands on separate lines returns all commands', ->
            lexer = createLexer 'alpha: bravo \n charlie: delta \n echo: foxtrot'
            lexer.next().name.should.equal 'alpha'
            lexer.next().name.should.equal 'charlie'
            lexer.next().name.should.equal 'echo'
            expect(lexer.next()).to.be.null

    describe 'a command with', ->

        it 'only a name has no arguments', ->
            command = createLexer('alpha:').next()
            command.argText.should.equal ''
            command.args.should.eql []

        it 'one argument has only that argument', ->
            command = createLexer('alpha: bravo').next()
            command.argText.should.equal 'bravo'
            command.args.should.eql ['bravo']

        it 'multiple arguments has all of them', ->
            command = createLexer('alpha: bravo, charlie, delta').next()
            command.argText.should.equal 'bravo, charlie, delta'
            command.args.should.eql ['bravo', 'charlie', 'delta']

        it 'only a heredoc has it recorded in the right places', ->
            command = createLexer('alpha: <<-END\nbravo charlie\nEND').next()
            command.hereDoc.should.equal 'bravo charlie'
            command.args.should.eql ['bravo charlie']
            command.argText.should.equal 'bravo charlie'

        it 'multiple args and a hereDoc is built correctly', ->
            command = createLexer('alpha: bravo, charlie <<-END\ndelta echo\nfoxtrot\nEND').next()
            command.hereDoc.should.equal 'delta echo\nfoxtrot'
            command.argText.should.equal 'bravo, charlie, delta echo\nfoxtrot'
            command.args.should.eql ['bravo', 'charlie', 'delta echo\nfoxtrot']

    describe 'file name is assigned correctly when', ->

        it 'no file markers are given', ->
            lexer = createLexer 'alpha: bravo\ncharlie: delta'
            lexer.next().fileName.should.equal 'file.cg'
            lexer.next().fileName.should.equal 'file.cg'

        it 'commands appear before the first file marker', ->
            lexer = createLexer 'alpha: bravo\n#FILE file2.cg\ncharlie: delta'
            lexer.next().fileName.should.equal 'file.cg'
            lexer.next().fileName.should.equal 'file2.cg'

        it 'multiple file markers are used', ->
            lexer = createLexer '#FILE file1.cg\na: b\n#FILE file2.cg\nc: d\n#FILE file3.cg\ne: f'
            lexer.next().fileName.should.equal 'file1.cg'
            lexer.next().fileName.should.equal 'file2.cg'
            lexer.next().fileName.should.equal 'file3.cg'

    describe 'line numbers are assigned correctly when', ->

        it 'commands are listed one after another', ->
            lexer = createLexer 'alpha: bravo\ncharlie: delta\necho: foxtrot'
            lexer.next().lineNumber.should.equal 1
            lexer.next().lineNumber.should.equal 2
            lexer.next().lineNumber.should.equal 3

        it 'commands are separated by blank lines and comments', ->
            lexer = createLexer '# foo\n\nalpha: bravo\n\ncharlie: delta\n\n# bar\n\necho: foxtrot'
            lexer.next().lineNumber.should.equal 3
            lexer.next().lineNumber.should.equal 5
            lexer.next().lineNumber.should.equal 9

        it 'commands include hereDocs', ->
            lexer = createLexer 'alpha: <<-END\nbravo charlie\nEND\ndelta: \n\necho: '
            lexer.next().lineNumber.should.equal 1
            lexer.next().lineNumber.should.equal 4
            lexer.next().lineNumber.should.equal 6

        it 'file markers are used', ->
            lexer = createLexer '#FILE file1.cg\nalpha: \n#FILE file2.cg\n\nbravo: \n\n#FILE file3.cg\n\n\ncharlie: '
            lexer.next().lineNumber.should.equal 1
            lexer.next().lineNumber.should.equal 2
            lexer.next().lineNumber.should.equal 3
