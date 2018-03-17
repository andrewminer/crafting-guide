###
Crafting Guide - multiblock_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require '../../../base_controller'

########################################################################################################################

module.exports = class MultiblockController extends BaseController

    @::HOVER_TIMEOUT = 5000 # ms

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
        options.templateName = 'item_page/multiblock_viewer/multiblock'
        super options

        @_currentLayer = 0
        @_blockCache   = null
        @_imageLoader  = options.imageLoader
        @_modPack      = options.modPack
        @_onHovering   = options.onHovering ?= (itemDisplay)-> # do nothing

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

    # Property Methods #############################################################################

    Object.defineProperties @prototype,
        currentLayer:
            get: -> return @_currentLayer

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$outline = @$('.outline')
        super

    refresh: ->
        @$el.css 'height':@_computeMinHeight(), 'width':@_computeMinWidth()

        @_refreshBlockCache()
        @_refreshAllBlocks()
        super

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

        zindex = ((@model.width - x) + (@model.depth - z) + ((@model.width * @model.depth) * y)) * 2

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

    _endHovering: ->
        @$outline.css opacity:0.0
        @_hoverTimer = null
        @_onHovering null

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
                @_registerHoverHandlers $block, y, itemDisplay
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
        if @_endHovering? then @_endHovering()

        for x in [0...@model.width]
            for y in [0...@model.height]
                for z in [0...@model.depth]
                    @_refreshBlock(x, y, z)

    _registerHoverHandlers: ($el, y, itemDisplay)->
        startHovering = =>
            return unless y is @_currentLayer
            zIndex = parseInt($el.css('z-index')) + 1
            zIndex = if _.isNaN(zIndex) then 0 else zIndex

            @$outline.css opacity:1.0, top:$el.css('top'), left:$el.css('left'), 'z-index':zIndex
            @_onHovering itemDisplay

            if @_hoverTimer? then clearTimeout @_hoverTimer
            @_hoverTimer = setTimeout (=> @_endHovering()), @HOVER_TIMEOUT

        $el.hover startHovering, (->)
