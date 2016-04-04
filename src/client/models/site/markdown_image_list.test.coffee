#
# Crafting Guide - markdown_image_list.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

MarkdownImageList = require './markdown_image_list'

########################################################################################################################

list = null

########################################################################################################################

describe 'markdown_image_list.coffee', ->

    beforeEach ->
        list = new MarkdownImageList {}, client:{fetchFile:sinon.stub().returns(w.promise(->))}

    describe '_analyzeMarkdownText', ->

        it 'finds nothing in a null string', ->
            list.all.should.eql []

        it 'finds nothing in an empty string', ->
            list.markdownText = ''
            list.all.should.eql []

        it 'finds nothing when there are no images in the markdown', ->
            list.markdownText = 'alpha bravo charlie delta'
            list.all.should.eql []

        it 'finds a single image alone', ->
            list.markdownText = '![](alpha.png)'
            (i.fileName for i in list.all).sort().should.eql ['alpha.png']

        it 'finds a single image inside a markdown document', ->
            list.markdownText = '# alpha\n bravo charlie\n\n| ![](alpha.png) |\n|:----------:|\ndelta'
            (i.fileName for i in list.all).sort().should.eql ['alpha.png']

        it 'finds multiple images inside a markdown document', ->
            list.markdownText = '| Images |\n|:------:|\n| ![](alpha.png) |\n| ![](bravo.png) |\n| ![](charlie.png) |\n'
            (i.fileName for i in list.all).sort().should.eql ['alpha.png', 'bravo.png', 'charlie.png']

        it 'adds new images when markdown changes', ->
            list.markdownText = '![](alpha.png)'
            (i.fileName for i in list.all).sort().should.eql ['alpha.png']

            list.markdownText = '![](alpha.png), ![](bravo.png)'
            (i.fileName for i in list.all).sort().should.eql ['alpha.png', 'bravo.png']

        it 'removes missing images when markdown changes', ->
            list.markdownText = '![](alpha.png), ![](bravo.png)'
            (i.fileName for i in list.all).sort().should.eql ['alpha.png', 'bravo.png']

            list.markdownText = '![](alpha.png)'
            (i.fileName for i in list.all).sort().should.eql ['alpha.png']

        it 'does not change remaining images when still present in changed markdown', ->
            list.markdownText = '![](alpha.png)'
            list.all[0].testField = 'foo'

            list.markdownText = '![](alpha.png) bravo'
            list.all[0].testField.should.equal 'foo'
