###
Crafting Guide - string_builder.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class StringBuilder

    constructor: (options={})->
        options.indent       ?= 0
        options.indentString ?= '    '

        @context = options.context

        @_initialIndent = options.indent
        @_indent        = options.indent
        @_indentString  = options.indentString
        @_pieces        = []

    # Public Methods ###############################################################################

    call: ->
        args = (arg for arg in arguments)
        callback = args.pop()
        args.unshift this
        return unless _.isFunction callback

        callback.apply null, args

    clear: ->
        @_indent = @_initialIndent
        @_pieces = []
        return this

    indent: ->
        @_indent += 1
        return this

    line: (args...)->
        @push.apply this, args
        @push '\n'

    loop: (list, options={})->
        options.start     ?= ''
        options.end       ?= ''
        options.indent    ?= false
        options.delimiter ?= ', '
        options.onEach    ?= (builder, item)-> builder.push item

        @_pushText options.start
        if options.indent then @indent()

        isFirst = true
        for item in list
            if not isFirst then @push options.delimiter
            isFirst = false
            options.onEach this, item

        if options.indent then @outdent()
        @_pushText options.end

        return this

    onlyIf: (condition, callback=null)->
        return this unless condition

        callback ?= (builder)-> # do nothing
        callback this
        return this

    outdent: ->
        @_indent -= 1
        return this

    push: ->
        for i in [0...arguments.length]
            arg = arguments[i]

            if _.isArray arg
                @push.apply this, arg
            else if _.isString arg
                @_pushText arg
            else
                @_pushText "#{arg}"

        return this

    # Object Overrides #############################################################################

    toString: ->
        return @_pieces.join ''

    # Private Methods ##############################################################################

    _pushIndent: ->
        for i in [0...@_indent]
            @_pieces.push @_indentString

    _pushText: (text)->
        return if text.length is 0
        index = 0

        if @_pieces.length > 0
            lastPiece = @_pieces[@_pieces.length-1]
            if lastPiece[lastPiece.length-1] is '\n'
                @_pushIndent()

        while true
            newLineAt = text.indexOf '\n', index
            break if newLineAt is -1

            @_pieces.push text[index..newLineAt]
            index = newLineAt + 1

            break if newLineAt is text.length - 1
            @_pushIndent()

        if text.length > index
            @_pieces.push text[index...text.length]
