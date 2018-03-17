#
# Crafting Guide - video_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../base_controller'

########################################################################################################################

module.exports = class VideoController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        options.templateName = 'common/video'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$iframe = @$('iframe')
        @$caption  = @$('.caption p')
        super

    refresh: ->
        @$caption.html @model.name
        @$iframe.attr 'src', @_createYouTubeUrl()
        super

    # Private ######################################################################################

    _createYouTubeUrl: ->
        return "http://www.youtube.com/embed/#{@model.youTubeId}?modestbranding=1&autohide=1&showinfo=0"
