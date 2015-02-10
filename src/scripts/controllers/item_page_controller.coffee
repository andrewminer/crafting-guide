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
{Text}               = require '../constants'
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
        @_usedToMakeController = @addChild ItemGroupController, '.usedToMake .view__item_group', modPack:@_modPack

        @$byline                = @$('.byline')
        @$bylineLink            = @$('.byline a')
        @$craftingPlanLink      = @$('a.craftingPlan')
        @$name                  = @$('h1.name')
        @$recipeContainer       = @$('.recipes .panel')
        @$recipesSection        = @$('.recipes')
        @$similarContainer      = @$('.similar')
        @$titleImage            = @$('.titleImage img')
        @$usedToMakeContainer = @$('.usedToMake')
        super

    refresh: ->
        $('title').html if @model.item? then "#{@model.item.name} | #{Text.title}" else Text.title
        @_resolveItemSlug()

        display = @_modPack.findItemDisplay @model.item?.slug
        if display?
            @$craftingPlanLink.attr href:display.craftingUrl
            @$craftingPlanLink.fadeIn duration:Duration.fast
            @_imageLoader.load display.iconUrl, @$titleImage
            @$name.html display.itemName
        else
            @$craftingPlanLink.fadeOut duration:Duration.fast
            @$titleImage.removeAttr 'src'
            @$name.html ''

        @_refreshByline()
        @_refreshRecipes()
        @_refreshSimilarItems()
        @_refreshUsedToMake()

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.craftingPlan': 'routeLinkClick'
            'click .byline a':      'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshByline: ->
        mod = @model.item?.modVersion?.mod
        if mod?.name?.length > 0
            @$bylineLink.attr 'href', Url.mod modSlug:mod.slug
            @$bylineLink.html mod.name
            @$byline.fadeIn duration:Duration.fast
        else
            @$byline.fadeOut duration:Duration.fast

    _refreshUsedToMake: ->
        @_usedToMakeController.title = 'Used to Make'

        @_usedToMakeController.model = @model.findComponentInItems()
        if @_usedToMakeController.model?
            @$usedToMakeContainer.fadeIn duration:Duration.fast
        else
            @$usedToMakeContainer.fadeOut duration:Duration.fast

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
