###
Crafting Guide - image_loader.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

{Duration} = require '../constants'

########################################################################################################################

module.exports = class ImageLoader

    constructor: (options={})->
        options.defaultUrl   ?= ''
        options.onLoading    ?= -> @hide()
        options.onLoad       ?= -> @fadeIn Duration.fast

        @defaultUrl   = options.defaultUrl
        @onLoading    = options.onLoading
        @onLoad       = options.onLoad

        @_images = {}

    # Class Methods ################################################################################

    @load: (imageUrl, $el, options={}) ->
        loader = new ImageLoader options
        loader.load $el, options
        return loader

    # Public Methods ###############################################################################

    isLoaded: (imageUrl)->
        data = @_images[imageUrl]
        return false unless data?
        return data.isLoaded

    load: (imageUrl, $el)->
        data = @preload imageUrl
        return if $el.attr('src').indexOf(imageUrl) isnt -1

        if @onLoading? then @onLoading.call $el
        $el.data 'isLoading', true
        $el.data 'isLoaded', false

        if data.isLoaded?
            @_loadImageIntoElement data.imageUrl, $el
        else
            if @defaultUrl? then $el.attr 'src', @defaultUrl
            if data.elements.indexOf($el) is -1 then data.elements.push $el

        return this

    preload: (imageUrl)->
        data = @_images[imageUrl]
        if not data?
            data = imageUrl:imageUrl, elements:[], image:new Image, isLoaded:false
            @_images[imageUrl] = data

            data.image        = new Image
            data.image.onload = => @_onImageLoaded data
            data.image.src    = imageUrl

        return data

    # Private Methods ##############################################################################

    _onImageLoaded: (data)->
        for $el in data.elements
            @_loadImageIntoElement data.imageUrl, $el

        data.elements = []
        data.isLoaded = true

    _loadImageIntoElement: (imageUrl, $el)->
        $el.data 'isLoading', false
        $el.data 'isLoaded', true
        $el.attr 'src', imageUrl

        if @onLoad? then @onLoad.call $el
