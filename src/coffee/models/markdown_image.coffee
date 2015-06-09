###
Crafting Guide - markdown_image.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_            = require 'underscore'
EditableFile = require './editable_file'

########################################################################################################################

module.exports = class MarkdownImage extends EditableFile

    # Property Methods #############################################################################

    getImageUrl: ->
        if @mimeType? and @encodedData?
            return "data:#{@mimeType};base64,#{@encodedData}"
        else
            return @fullPath

    Object.defineProperties @prototype,
        imageUrl: {get:@prototype.getImageUrl}
