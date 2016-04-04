#
# Crafting Guide - fs.extensions.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fs = require './fs.extensions'

########################################################################################################################

describe 'fs.extensions.coffee', ->

    describe 'rmdirRfSync', ->

        beforeEach ->
            fs.mkdirSync '.tmp'

        afterEach ->
            fs.rmdirRfSync '.tmp'

        it 'can remove a single file', ->
            fs.writeFileSync '.tmp/alpha'

            fs.rmdirRfSync '.tmp/alpha'
            func = -> fs.statSync '.tmp/alpha'
            expect(func).to.throw Error, 'no such file'

        it 'can remove an empty directory', ->
            fs.mkdirSync '.tmp/alpha'

            fs.rmdirRfSync '.tmp/alpha'
            func = -> fs.statSync '.tmp/alpha'
            expect(func).to.throw Error, 'no such file'

        it 'can remove a directory with a file', ->
            fs.mkdirSync '.tmp/alpha'
            fs.writeFileSync '.tmp/bravo'

            fs.rmdirRfSync '.tmp/alpha'
            func = -> fs.statSync '.tmp/alpha'
            expect(func).to.throw Error, 'no such file'

        it 'can remove a nested sub-directory with a file', ->
            fs.mkdirSync '.tmp/alpha'
            fs.writeFileSync '.tmp/bravo'
            fs.mkdirSync '.tmp/alpha/charlie'
            fs.writeFileSync '.tmp/alpha/charlie/delta'

            fs.rmdirRfSync '.tmp/alpha'
            func = -> fs.statSync '.tmp/alpha'
            expect(func).to.throw Error, 'no such file'
