###
Crafting Guide - string_builder.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

StringBuilder = require '../src/scripts/models/string_builder'

########################################################################################################################

builder = null

########################################################################################################################

describe 'string_builder.coffee', ->

    beforeEach -> builder = new StringBuilder

    describe 'call', ->

        it 'works with no arguments', ->
            builder.call (b)-> b.push 'foo'
            builder.toString().should.equal 'foo'

        it 'works with multiple arguments', ->
            builder.call 'foo', 'bar', 'baz', (builder, a, b, c)-> builder.loop [a, b, c]
            builder.toString().should.equal 'foo, bar, baz'

    describe 'loop', ->

        it 'can make an empty list', ->
            builder.loop [], start:'[', end:']'
            builder.toString().should.equal '[]'

        it 'can make a list with a single element', ->
            builder.loop ['foo'], start:'[', end:']'
            builder.toString().should.equal '[foo]'

        it 'can make a list with many elements', ->
            builder.loop ['foo', 'bar', 'baz'], start:'[', end:']'
            builder.toString().should.equal '[foo, bar, baz]'

        it 'can make a list with a custom callback', ->
            builder.loop ['foo', 'bar', 'baz'], start:'[', end:']', onEach:(b, i)-> b.push "\"#{i}\""
            builder.toString().should.equal '["foo", "bar", "baz"]'

        it 'can use a custom delimiter', ->
            builder.loop ['foo', 'bar', 'baz'], delimiter:'|'
            builder.toString().should.equal 'foo|bar|baz'

        it 'can indent content', ->
            builder.loop ['foo', 'bar', 'baz'], start:'[\n', end:'\n]', delimiter:',\n', indent:true
            builder.toString().should.equal '[\n    foo,\n    bar,\n    baz\n]'

    describe 'onlyIf', ->

        it 'calls the callback on true', ->
            builder.onlyIf true, (b)-> b.push 'foo'
            builder.toString().should.equal 'foo'

    describe 'push', ->

        it 'can build a simple string', ->
            builder.push('foo').push(' bar').push(' baz')
            builder.toString().should.equal 'foo bar baz'

        it 'can build a multi-line string', ->
            builder.push('foo').push('\nbar\n').push('baz')
            builder.toString().should.equal 'foo\nbar\nbaz'

        it 'can build an indented multi-line string', ->
            builder
                .push 'foo\n'
                .indent()
                    .push 'bar\n'
                .outdent()
                .push 'baz'

            builder.toString().should.equal 'foo\n    bar\nbaz'

        it 'can pick apart multiple newlines in a single chunk', ->
            builder.indent().push('foo\nbar\nbaz').outdent().push('\nbif')
            builder.toString().should.equal 'foo\n    bar\n    baz\nbif'