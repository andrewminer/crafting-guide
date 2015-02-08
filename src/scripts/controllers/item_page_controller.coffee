###
Crafting Guide - item_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController      = require './base_controller'
{Duration}          = require '../constants'
{Event}             = require '../constants'
ImageLoader         = require './image_loader'
Item                = require '../models/item'
ItemGroupController = require './item_group_controller'
ItemPage            = require '../models/item_page'
{Url}               = require '../constants'

########################################################################################################################

module.exports = class ItemPageController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.itemSlug? then throw new Error 'options.itemSlug is required'

        options.imageLoader  ?= new ImageLoader defaultUrl:'/images/unknown.png'
        options.model        ?= new ItemPage modPack:options.modPack
        options.templateName ?= 'item_page'

        super options

        @_imageLoader = options.imageLoader
        @_itemSlug    = options.itemSlug
        @_modPack     = options.modPack

        @_modPack.on Event.change, => @_resolveItemSlug()
        @_resolveItemSlug()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_similarItemsController = @addChild ItemGroupController, '.similar .view__item_group', modPack:@_modPack
        @_usedInMakingController  = @addChild ItemGroupController, '.usedInMaking .view__item_group', modPack:@_modPack

        @$byline               = @$('.byline')
        @$bylineLink           = @$('.byline a')
        @$usedInMakingContainer = @$('.usedInMaking')
        @$name                 = @$('h1.name')
        @$recipeContainer      = @$('.recipe')
        @$similarContainer     = @$('.similar')
        @$titleImage           = @$('.titleImage img')
        super

    refresh: ->
        display = @_modPack.findItemDisplay @model.item?.slug
        if display?
            @_imageLoader.load display.iconUrl, @$titleImage
            @$name.html display.itemName
        else
            @$titleImage.removeAttr 'src'
            @$name.html ''

        @_refreshByline()
        @_refreshSimilarItems()
        @_refreshComponentIn()

        super

    # Private Methods ##############################################################################

    _refreshByline: ->
        mod = @model.item?.modVersion?.mod
        if mod?.name?.length > 0
            @$bylineLink.attr 'href', Url.mod modSlug:mod.slug
            @$bylineLink.html mod.name
            @$byline.fadeIn duration:Duration.fast
        else
            @$byline.fadeOut duration:Duration.fast

    _refreshComponentIn: ->
        @_usedInMakingController.title = 'Used in Making'

        @_usedInMakingController.model = @model.findComponentInItems()
        if @_usedInMakingController.model?
            @$usedInMakingContainer.fadeIn duration:Duration.fast
        else
            @$usedInMakingContainer.fadeOut duration:Duration.fast

    _refreshSimilarItems: ->
        group = @model.item?.group
        if group? and group isnt Item.Group.Other
            @_similarItemsController.title = "Other #{group}"
            @_similarItemsController.model = @model.findSimilarItems()
        else
            @_similarItemsController.model = null

        if @_similarItemsController.model?
            @$similarContainer.fadeIn duration:Duration.fast
        else
            @$similarContainer.fadeOut duration:Duration.fast

    _resolveItemSlug: ->
        @model.item = @_modPack.findItem @_itemSlug, includeDisabled:true

