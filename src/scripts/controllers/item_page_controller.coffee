###
Crafting Guide - item_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController       = require './base_controller'
{Duration}           = require '../constants'
{Event}              = require '../constants'
FullRecipeController = require './full_recipe_controller'
ImageLoader          = require './image_loader'
Item                 = require '../models/item'
ItemGroupController  = require './item_group_controller'
ItemPage             = require '../models/item_page'
{Url}                = require '../constants'

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

        @_modPack.on Event.change, => @refresh()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_similarItemsController = @addChild ItemGroupController, '.similar .view__item_group', modPack:@_modPack
        @_usedInMakingController = @addChild ItemGroupController, '.usedInMaking .view__item_group', modPack:@_modPack

        @$byline                = @$('.byline')
        @$bylineLink            = @$('.byline a')
        @$name                  = @$('h1.name')
        @$recipeContainer       = @$('.recipes .panel')
        @$recipesSection        = @$('.recipes')
        @$similarContainer      = @$('.similar')
        @$titleImage            = @$('.titleImage img')
        @$usedInMakingContainer = @$('.usedInMaking')
        super

    refresh: ->
        @_resolveItemSlug()

        display = @_modPack.findItemDisplay @model.item?.slug
        if display?
            @_imageLoader.load display.iconUrl, @$titleImage
            @$name.html display.itemName
        else
            @$titleImage.removeAttr 'src'
            @$name.html ''

        @_refreshByline()
        @_refreshRecipes()
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
        @_usedInMakingController.title = 'Used to Make'

        @_usedInMakingController.model = @model.findComponentInItems()
        if @_usedInMakingController.model?
            @$usedInMakingContainer.fadeIn duration:Duration.fast
        else
            @$usedInMakingContainer.fadeOut duration:Duration.fast

    _refreshRecipes: ->
        @_recipeControllers ?= []
        index = 0

        recipes = @model.findRecipes()
        if recipes?
            @$recipesSection.fadeIn duration:Duration.normal

            for recipe in @model.findRecipes()
                controller = @_recipeControllers[index]
                if not controller?
                    controller = new FullRecipeController modPack:@_modPack, model:recipe
                    @_recipeControllers.push controller
                    controller.render()
                    controller.$el.hide()
                    @$recipeContainer.append controller.$el
                    controller.$el.fadeIn duration:Duration.normal
                else
                    controller.model = recipe
                index++
        else
            @$recipesSection.fadeOut duration:Duration.fast

        while @_recipeControllers.length > index
            controller = @_recipeControllers.pop()
            controller.fadeOut duration:Duration.fast, complete:-> controller.$el.remove()

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
        oldItem = @model.item
        @model.item = @_modPack.findItem @_itemSlug, includeDisabled:true
        newItem = @model.item
