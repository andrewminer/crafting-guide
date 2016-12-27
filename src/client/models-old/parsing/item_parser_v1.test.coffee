#
# Crafting Guide - item_parser_v1.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Item         = require '../game/item'
ItemParserV1 = require './item_parser_v1'

########################################################################################################################

baseText = item = parser = null

########################################################################################################################

describe 'item_parser_v1.coffee', ->

    beforeEach ->
        item   = new Item name:'alpha'
        parser = new ItemParserV1 model:item

    describe 'officialUrl', ->

        it 'may be omitted', ->
            parser.parse 'schema: 1\nvideo: youtubeid, Video Alpha\ndescription: Bravo, Charlie'
            expect(item.officialUrl).to.be.null

        it 'is assigned properly when given', ->
            parser.parse 'schema: 1\nofficialUrl: http://testurl.com'
            item.officialUrl.should.equal 'http://testurl.com'

        it 'does not allow duplicate declarations', ->
            func = -> parser.parse 'schema: 1\nofficialUrl: http://testurl.com\nofficialUrl: http://testurl2.com'
            expect(func).to.throw Error, 'duplicate'

        it 'does not allow an empty value if given', ->
            func = -> parser.parse 'schema: 1\nofficialUrl:'
            expect(func).to.throw Error, 'empty'

    describe 'description', ->

        it 'may be omitted', ->
            parser.parse 'schema: 1\nvideo: youTubeId, Video Alpha\nofficialUrl: http://testurl.com'
            expect(item.description).to.be.null

        it 'is assigned properly when given', ->
            parser.parse 'schema: 1\ndescription: Alpha Bravo Charlie'
            item.description.should.equal 'Alpha Bravo Charlie'

        it 'can be a heredoc', ->
            parser.parse 'schema: 1\ndescription: <<-END\nAlpha\nBravo\nCharlie\nEND'
            item.description.should.equal 'Alpha\nBravo\nCharlie'

        it 'concatenates multiple declarations', ->
            parser.parse 'schema: 1\ndescription: Alpha\ndescription: Bravo'
            item.description.should.equal 'Alpha\nBravo'

    describe 'video', ->

        it 'may be omitted', ->
            parser.parse 'schema: 1\nofficialUrl: http://testurl.com\ndescription: Alpha Bravo Charlie'
            item.videos.should.eql []

        it 'is assigned properly when given', ->
            parser.parse 'schema: 1\nvideo: youtubeid, Alpha Bravo'
            item.videos[0].should.eql youTubeId:'youtubeid', name:'Alpha Bravo'
            item.videos.length.should.equal 1

        it 'may be included multiple times', ->
            parser.parse 'schema: 1\nvideo: youtubeid1, Alpha\nvideo: youtubeid2, Bravo'
            item.videos[0].should.eql youTubeId:'youtubeid1', name:'Alpha'
            item.videos[1].should.eql youTubeId:'youtubeid2', name:'Bravo'
            item.videos.length.should.equal 2

        it 'requires a YouTubeId and name', ->
            func = -> parser.parse 'schema: 1\nvideo: alpha'
            expect(func).to.throw Error, 'requires a name'

    describe 'unparsing', ->

        it 'can round-trip a fully described item', ->
            text = """
                schema: 1

                officialUrl: http://testurl.com

                description: <<-END
                Alpha
                Bravo
                END

                video: youtubeid1, Alpha Bravo
                video: youtubeid2, Charlie Delta


            """
            parser.parse text
            parser.unparse().should.equal text
