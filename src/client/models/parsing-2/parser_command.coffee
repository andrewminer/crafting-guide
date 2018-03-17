#
# Crafting Guide - parser_command.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = class ParserCommand

    constructor: (options={})->
        if not options.name? then throw 'options.name is required'
        if not options.fileName? then throw new 'options.fileName is required'
        if not options.lineNumber? then throw 'options.lineNumber is required'

        {@name, @fileName, @lineNumber, @argText, @args, @hereDoc} = options

    # Property Methods #############################################################################

    getLocation: ->
        return "#{@fileName}:#{@lineNumber}"

    Object.defineProperties @prototype,
        location: { get:@::getLocation }

    # Object Overrides #############################################################################

    toString: ->
        result = "#{@fileName}:#{@lineNumber}    #{@name}: #{@argText}"
        if @hereDoc?
            result += " <<- END\n#{@hereDoc}\nEND"
        return result
