###
Crafting Guide - stack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
{Event}        = require '../constants'
ImageLoader    = require './image_loader'

########################################################################################################################

module.exports = class StackController extends BaseController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        options.editable     ?= false
        options.onRemove     ?= (stack)-> # do nothing
        options.templateName  = 'stack'
        super options

        @editable     = options.editable
        @modPack      = options.modPack
        @onRemove     = options.onRemove
        @_imageLoader = options.imageLoader

        @modPack.on Event.change, => @tryRefresh()

    # Event Methods ################################################################################

    onRemoveClicked: ->
        @onRemove @model

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$action        = @$('.action')
        @$image         = @$('.icon img')
        @$nameLink      = @$('.name a')
        @$quantityField = @$('.quantity p')
        @$removeButton  = @$('button.remove')
        super

    refresh: ->
        display = @modPack.findItemDisplay @model.itemSlug

        @_imageLoader.load display.iconUrl, @$image
        @$nameLink.html display.itemName
        @$nameLink.attr 'href', display.itemUrl
        @$quantityField.html @model.quantity

        @$action.css display:(if @editable then 'table-cell' else 'none')

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click button.remove': 'onRemoveClicked'
            'click .name a':       'routeLinkClick'
