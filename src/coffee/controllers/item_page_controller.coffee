###
Crafting Guide - item_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

AdsenseController    = require './adsense_controller'
FullRecipeController = require './full_recipe_controller'
ImageLoader          = require './image_loader'
Item                 = require '../models/item'
ItemGroupController  = require './item_group_controller'
ItemPage             = require '../models/item_page'
ItemSlug             = require '../models/item_slug'
PageController       = require './page_controller'
VideoController      = require './video_controller'
{Duration}           = require '../constants'
{Event}              = require '../constants'
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
        @modPack     = options.modPack
        @_itemSlug   = options.itemSlug

        @modPack.on Event.change, => @tryRefresh()

    # PageController Overrides #####################################################################

    getTitle: ->
        return @model.item?.name

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'

        @_similarItemsController = @addChild ItemGroupController, '.similar .view__item_group',
            imageLoader: @imageLoader
            modPack:     @modPack

        @_usedAsToolToMakeController = @addChild ItemGroupController, '.usedAsToolToMake .view__item_group',
            imageLoader: @imageLoader
            modPack:     @modPack

        @_usedToMakeController = @addChild ItemGroupController, '.usedToMake .view__item_group',
            imageLoader: @imageLoader
            modPack:     @modPack

        @$byline                  = @$('.byline')
        @$bylineLink              = @$('.byline a')
        @$craftingPlanLink        = @$('a.craftingPlan')
        @$descriptionPanel        = @$('.description .panel')
        @$descriptionSection      = @$('.description')
        @$name                    = @$('h1.name')
        @$recipeContainer         = @$('.recipes .panel')
        @$recipesSection          = @$('.recipes')
        @$recipesSectionTitle     = @$('.recipes h2')
        @$similarSection          = @$('.similar')
        @$titleImage              = @$('.titleImage img')
        @$usedAsToolToMakeSection = @$('.usedAsToolToMake')
        @$usedToMakeSection       = @$('.usedToMake')
        @$videosContainer         = @$('.videos .panel')
        @$videosSection           = @$('.videos')
        @$videosSectionTitle      = @$('.videos h2')
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
        @_refreshDescription()
        @_refreshRecipes()
        @_refreshSimilarItems()
        @_refreshUsedAsToolToMake()
        @_refreshUsedToMake()
        @_refreshVideos()

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

    _refreshDescription: ->
        description = @model.compileDescription()
        if description?
            @$descriptionPanel.html description
            @$descriptionSection.slideDown duration:Duration.normal
        else
            @$descriptionSection.slideUp duration:Duration.normal

    _refreshRecipes: ->
        @_recipeControllers ?= []
        index = 0

        recipes = @model.findRecipes()
        if recipes?
            @$recipesSection.slideDown duration:Duration.normal
            @$recipesSectionTitle.html if recipes.length is 1 then 'Recipe' else 'Recipes'

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

    _refreshUsedAsToolToMake: ->
        @_usedAsToolToMakeController.title = 'Used as Tool to Make'

        @_usedAsToolToMakeController.model = @model.findToolForRecipes()
        if @_usedAsToolToMakeController.model?
            @$usedAsToolToMakeSection.slideDown duration:Duration.normal
        else
            @$usedAsToolToMakeSection.slideUp duration:Duration.normal

    _refreshUsedToMake: ->
        @_usedToMakeController.title = 'Used to Make'

        @_usedToMakeController.model = @model.findComponentInItems()
        if @_usedToMakeController.model?
            @$usedToMakeSection.slideDown duration:Duration.normal
        else
            @$usedToMakeSection.slideUp duration:Duration.normal

    _refreshVideos: ->
        @_videoControllers ?= []
        index = 0

        videos = @model?.item.videos or []
        if videos? and videos.length > 0
            @$videosSection.slideDown duration:Duration.normal
            @$videosSectionTitle.html if videos.length is 1 then 'Video' else 'Videos'

            for video in videos
                controller = @_videoControllers[index]
                if not controller?
                    controller = new VideoController model:video
                    @_videoControllers.push controller
                    controller.render()
                    @$videosContainer.append controller.$el
                else
                    controller.model = video
                index++
        else
            @$videosSection.slideUp duration:Duration.normal

        while @_videoControllers.length > index
            controller = @_videoControllers.pop()
            controller.$el.slideUp duration:Duration.normal, complete:-> controller.$el.remove()

    _resolveItemSlug: ->
        return if @model.item?

        item = @modPack.findItem @_itemSlug, includeDisabled:false
        if item?
            if not ItemSlug.equal item.slug, @_itemSlug
                router.navigate Url.item(modSlug:item.slug.mod, itemSlug:item.slug.item), trigger:true
                return

            @model.item = item
            item.fetch()
            item.on Event.sync, => @refresh()
