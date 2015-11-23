###
Crafting Guide - multiblock_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

$              = require 'jquery'
_              = require '../underscore_mixins'
BaseController = require './base_controller'

########################################################################################################################

module.exports = class MultiblockController extends BaseController

    @::IMAGE_SIZE = 48 # px

    @::X_LAYER_H_SHIFT = -24 # px
    @::Z_LAYER_H_SHIFT = +24 # px

    @::X_LAYER_V_SHIFT = -12 # px
    @::Y_LAYER_V_SHIFT = -30 # px
    @::Z_LAYER_V_SHIFT = -12 # px

    @::MAX_DROP_DELAY = 250 # ms

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'multiblock'
        super options

        @_currentLayer = 0
        @_blockCache   = null
        @_imageLoader  = options.imageLoader
        @_modPack      = options.modPack

    # Public Methods ###############################################################################

    goBackLayer: ->
        @_currentLayer = Math.max 0, @_currentLayer - 1
        @_refreshAllBlocks()

    goNextLayer: ->
        @_currentLayer = Math.min @model.height - 1, @_currentLayer + 1
        @_refreshAllBlocks()

    hasBackLayer: ->
        return false unless @model?
        return @_currentLayer > 0

    hasNextLayer: ->
        return false unless @model?
        return @_currentLayer < @model.height - 1

    # BaseController Overrides #####################################################################

    onDidRender: ->
        # do nothing

    refresh: ->
        @$el.css 'min-height':@_computeMinHeight(), 'min-width':@_computeMinWidth()

        @_refreshBlockCache()
        @_refreshAllBlocks()

    # Private Methods ##############################################################################

    _computePosition: (x, y, z, options={})->
        if not @model? then return left:0, top:-@IMAGE_SIZE, 'z-index':0, opacity:0.0

        options.hideUpperLayers ?= false
        pxWidth = @$el.width()
        pxHeight = @$el.height()

        left = ((pxWidth - @IMAGE_SIZE) / 2) + (x * @X_LAYER_H_SHIFT) + (z * @Z_LAYER_H_SHIFT)

        if options.hideUpperLayers and y > @_currentLayer
            top = 0
            opacity = 0.0
        else
            top = (pxHeight - @IMAGE_SIZE) + (x * @X_LAYER_V_SHIFT) + (z * @Z_LAYER_V_SHIFT) + (y * @Y_LAYER_V_SHIFT)
            opacity = 1.0

        zindex = (@model.width - x) + (@model.depth - z) + ((@model.width * @model.depth) * y)

        return left:left, top:top, 'z-index':zindex, opacity:opacity

    _computeMinHeight: ->
        return 0 unless @model?

        minHeight = Math.max(Math.abs(@model.width * @X_LAYER_V_SHIFT), Math.abs(@model.depth * @Z_LAYER_V_SHIFT))
        minHeight += Math.abs(@model.height * @Y_LAYER_V_SHIFT)
        minHeight += 2 * @IMAGE_SIZE
        return minHeight

    _computeMinWidth: ->
        return 0 unless @model?

        leftPosition  = @_computePosition @model.width, 0, 0
        rightPosition = @_computePosition 0, 0, @model.depth
        return rightPosition.left - leftPosition.left

    _randomDropDelay: ->
        return Math.random() * @MAX_DROP_DELAY

    _refreshBlockCache: ->
        @_blockCache = null
        return unless @model?

        @_blockCache = width:@model.width, height:@model.height, depth:@model.depth
        for x in [0...@model.width]
            @_blockCache[x] ?= {}
            for y in [0...@model.height]
                @_blockCache[x][y] ?= {}
                for z in [0...@model.depth]
                    @_blockCache[x][y][z] ?= null

        for el in @$('.block')
            $el = $(el)
            @_blockCache[$el.data('x')][$el.data('y')][$el.data('z')] = $el

    _refreshBlock: (x, y, z)->
        return unless @model?

        stack = @model.getStackAt x, y, z
        $block = @_blockCache[x][y][z]
        position = @_computePosition x, y, z, hideUpperLayers:true
        move = false

        if stack?
            itemDisplay = @_modPack.findItemDisplay stack.itemSlug

            if not $block?
                $block = $("<img alt='#{itemDisplay.itemName}' class='block' />")
                $block.css position, top:-@IMAGE_SIZE, opacity:0.0
                @_imageLoader.load itemDisplay.iconUrl, $block
                @_blockCache[x][y][z] = $block
                @$el.append $block
                move = true
            else
                $block.attr 'src', itemDisplay.iconUrl
                move = true
        else if $block?
            $block.attr 'src', ''
            move = true

        if move then _.delay (-> $block.css position), @_randomDropDelay()

    _refreshAllBlocks: ->
        return unless @model?

        for x in [0...@model.width]
            for y in [0...@model.height]
                for z in [0...@model.depth]
                    @_refreshBlock(x, y, z)
