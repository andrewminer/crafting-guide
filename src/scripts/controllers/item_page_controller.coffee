###
Crafting Guide - item_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

{Duration}           = require '../constants'
{Event}              = require '../constants'
FullRecipeController = require './full_recipe_controller'
ImageLoader          = require './image_loader'
Item                 = require '../models/item'
ItemGroupController  = require './item_group_controller'
ItemPage             = require '../models/item_page'
PageController       = require './page_controller'
{Text}               = require '../constants'
{Url}                = require '../constants'

########################################################################################################################

module.exports = class ItemPageController extends PageController

    constructor: (options={})->
        if not options.itemSlug? then throw new Error 'options.itemSlug is required'
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'

        options.model        ?= new ItemPage modPack:options.modPack
        options.templateName ?= 'item_page'

        super options

        @imageLoader = options.imageLoader
        @_itemSlug    = options.itemSlug
        @modPack     = options.modPack

        @modPack.on Event.change, => @tryRefresh()

    # PageController Overrides #####################################################################

    getTitle: ->
        return @model.item?.name

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_usedAsToolToMakeController = @addChild ItemGroupController, '.usedAsToolToMake .view__item_group',
            imageLoader: @imageLoader
            modPack:     @modPack

        @_similarItemsController = @addChild ItemGroupController, '.similar .view__item_group',
            imageLoader: @imageLoader
            modPack:     @modPack

        @_usedToMakeController = @addChild ItemGroupController, '.usedToMake .view__item_group',
            imageLoader: @imageLoader
            modPack:     @modPack

        @$usedAsToolToMakeSection = @$('.usedAsToolToMake')
        @$byline                  = @$('.byline')
        @$bylineLink              = @$('.byline a')
        @$craftingPlanLink        = @$('a.craftingPlan')
        @$name                    = @$('h1.name')
        @$recipeContainer         = @$('.recipes .panel')
        @$recipesSection          = @$('.recipes')
        @$similarSection          = @$('.similar')
        @$titleImage              = @$('.titleImage img')
        @$usedToMakeSection       = @$('.usedToMake')
        super

    refresh: ->
        @_resolveItemSlug()

        if @model.item?
            display = @modPack.findItemDisplay @model.item.slug
            @$craftingPlanLink.attr href:display.craftingUrl
            @$craftingPlanLink.fadeIn duration:Duration.fast
            @imageLoader.load display.iconUrl, @$titleImage
            @$name.html display.itemName

            @$el.slideDown duration:Duration.normal
        else
            @$el.slideUp duration:Duration.normal

        @_refreshByline()
        @_refreshRecipes()
        @_refreshSimilarItems()
        @_refreshUsedAsToolToMake()
        @_refreshUsedToMake()

        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.craftingPlan': 'routeLinkClick'
            'click .byline a':      'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshUsedAsToolToMake: ->
        @_usedAsToolToMakeController.title = 'Used as Tool to Make'

        @_usedAsToolToMakeController.model = @model.findToolForRecipes()
        if @_usedAsToolToMakeController.model?
            @$usedAsToolToMakeSection.slideDown duration:Duration.normal
        else
            @$usedAsToolToMakeSection.slideUp duration:Duration.normal

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
            @$usedToMakeSection.slideDown duration:Duration.normal
        else
            @$usedToMakeSection.slideUp duration:Duration.normal

    _refreshRecipes: ->
        @_recipeControllers ?= []
        index = 0

        recipes = @model.findRecipes()
        if recipes?
            @$recipesSection.slideDown duration:Duration.normal

            for recipe in @model.findRecipes()
                controller = @_recipeControllers[index]
                if not controller?
                    controller = new FullRecipeController imageLoader:@imageLoader, modPack:@modPack, model:recipe
                    @_recipeControllers.push controller
                    controller.render()
                    @$recipeContainer.append controller.$el
                else
                    controller.model = recipe
                index++
        else
            @$recipesSection.slideUp duration:Duration.normal

        while @_recipeControllers.length > index
            controller = @_recipeControllers.pop()
            controller.$el.slideUp duration:Duration.normal, complete:-> controller.$el.remove()

    _refreshSimilarItems: ->
        group = @model.item?.group
        if group? and group isnt Item.Group.Other
            @_similarItemsController.title = "Other #{group}"
            @_similarItemsController.model = @model.findSimilarItems()
        else
            @_similarItemsController.model = null

        if @_similarItemsController.model?
            @$similarSection.slideDown duration:Duration.normal
        else
            @$similarSection.slideUp duration:Duration.normal

    _resolveItemSlug: ->
        @model.item = @modPack.findItem @_itemSlug, includeDisabled:true
