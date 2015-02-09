###
Crafting Guide - stack_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'
ImageLoader    = require './image_loader'

########################################################################################################################

module.exports = class StackController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        options.imageLoader  ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.editable     ?= false
        options.onRemove     ?= (stack)-> # do nothing
        options.templateName  = 'stack'
        super options

        @editable     = options.editable
        @modPack      = options.modPack
        @onRemove     = options.onRemove
        @_imageLoader = options.imageLoader

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
        display = @modPack.findItemDisplay @model.slug

        @_imageLoader.load display.iconUrl, @$image
        @$nameLink.html display.itemName
        @$nameLink.attr 'href', display.itemUrl
        @$quantityField.html @model.quantity
        @$removeButton.css display:(if @editable then 'inherit' else 'none')

        @$action.css display:(if @ediable then 'table-cell' else 'none')

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click button.remove': 'onRemoveClicked'
