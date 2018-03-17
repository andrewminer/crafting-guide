#
# Crafting Guide - file_cache.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

FileCache = require './file_cache'

########################################################################################################################

describe 'file_cache.coffee', ->

    beforeEach ->
        @cache = new FileCache

    makeTestAjax = (text)->
        return (options)->
            options.success text, 'success', {url:options.url}

    it 'can load an archive with a single file', ->
        @cache._ajax = makeTestAjax '#file=alpha\nbravo charlie delta'
        @cache.loadArchive 'http://test'
            .then =>
                @cache.hasFile('alpha').should.equal true
                @cache.getFile('alpha').should.equal 'bravo charlie delta'

    it 'can load an archive with multiple files', ->
        @cache._ajax = makeTestAjax '#file=alpha\nbravo charlie\n#file=delta\necho foxtrot'
        @cache.loadArchive 'http://test'
            .then =>
                @cache.hasFile('alpha').should.equal true
                @cache.getFile('alpha').should.equal 'bravo charlie\n'
                @cache.hasFile('delta').should.equal true
                @cache.getFile('delta').should.equal 'echo foxtrot'

    it 'can load an archive without newlines', ->
        @cache._ajax = makeTestAjax '#file=alpha\nbravo charlie#file=delta\necho foxtrot'
        @cache.loadArchive 'http://test'
            .then =>
                @cache.hasFile('alpha').should.equal true
                @cache.getFile('alpha').should.equal 'bravo charlie'
                @cache.hasFile('delta').should.equal true
                @cache.getFile('delta').should.equal 'echo foxtrot'

    it 'can cope with an empty file in the middle of an archive', ->
        @cache._ajax = makeTestAjax '#file=alpha\nbravo charlie\n#file=delta\n#file=echo\nfoxtrot golf'
        @cache.loadArchive 'http://test'
            .then =>
                @cache.hasFile('alpha').should.equal true
                @cache.getFile('alpha').should.equal 'bravo charlie\n'
                @cache.hasFile('delta').should.equal true
                @cache.getFile('delta').should.equal ''
                @cache.hasFile('echo').should.equal true
                @cache.getFile('echo').should.equal 'foxtrot golf'

    it 'can cope with an empty file at the end of an archive', ->
        @cache._ajax = makeTestAjax '#file=alpha\nbravo charlie\n#file=delta'
        @cache.loadArchive 'http://test'
            .then =>
                @cache.hasFile('alpha').should.equal true
                @cache.getFile('alpha').should.equal 'bravo charlie\n'
                @cache.hasFile('delta').should.equal true
                @cache.getFile('delta').should.equal ''

    it 'can load multiple, non-overlapping archives', ->
        @cache._ajax = makeTestAjax '#file=alpha\nbravo charlie\n#file=delta\necho foxtrot'
        @cache.loadArchive 'http://test'

        @cache._ajax = makeTestAjax '#file=golf\nhotel india'
        @cache.loadArchive 'http://test2'
            .then =>
                @cache.hasFile('alpha').should.equal true
                @cache.getFile('alpha').should.equal 'bravo charlie\n'
                @cache.hasFile('delta').should.equal true
                @cache.getFile('delta').should.equal 'echo foxtrot'
                @cache.hasFile('golf').should.equal true
                @cache.getFile('golf').should.equal 'hotel india'
