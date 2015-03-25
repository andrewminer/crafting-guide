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

    # Event Methods ################################################################################

    craftingPlanButtonClicked: ->
        display = @modPack.findItemDisplay @model.item.slug
        router.navigate display.craftingUrl, trigger:true
        return false

    # PageController Overrides #####################################################################

    getTitle: ->
        return @model.item?.name

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'

        options                      = imageLoader:@imageLoader, modPack:@modPack, show:false
        @_similarItemsController     = @addChild ItemGroupController, '.view__item_group.similar', options
        @_usedAsToolToMakeController = @addChild ItemGroupController, '.view__item_group.usedAsToolToMake', options
        @_usedToMakeController       = @addChild ItemGroupController, '.view__item_group.usedToMake', options

        @$byline                  = @$('.byline')
        @$bylineLink              = @$('.byline a')
        @$descriptionPanel        = @$('.description .panel')
        @$descriptionSection      = @$('.description')
        @$name                    = @$('h1.name')
        @$officialPageLink        = @$('a.officialPage')
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
            @imageLoader.load display.iconUrl, @$titleImage
            @$name.html display.itemName

            if @model.item.officialUrl?
                @$officialPageLink.attr 'href', @model.item.officialUrl
                @show @$officialPageLink
            else
                @hide @$officialPageLink

            @show()
        else
            @hide()

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
            'click .markdown a':    'routeLinkClick'
            'click button':         'craftingPlanButtonClicked'

    # Private Methods ##############################################################################

    _refreshByline: ->
        mod = @model.item?.modVersion?.mod
        if mod?.name?.length > 0
            @$bylineLink.attr 'href', Url.mod modSlug:mod.slug
            @$bylineLink.html mod.name

            @show @$byline
        else
            @hide @$byline

    _refreshDescription: ->
        description = @model.compileDescription()
        if description?
            @$descriptionPanel.html description
            @show @$descriptionSection
        else
            @hide @$descriptionSection

    _refreshRecipes: ->
        @_recipeControllers ?= []
        index = 0

        recipes = @model.findRecipes()
        if recipes?.length > 0
            @$recipesSectionTitle.html if recipes.length is 1 then 'Recipe' else 'Recipes'

            for recipe in @model.findRecipes()
                controller = @_recipeControllers[index]
                if not controller?
                    controller = new FullRecipeController imageLoader:@imageLoader, modPack:@modPack, model:recipe
                    @_recipeControllers.push controller
                    @$recipeContainer.append controller.$el
                    controller.render()
                else
                    controller.model = recipe
                index++

            @show @$recipesSection
        else
            @hide @$recipesSection

        while @_recipeControllers.length > index
            @_recipeControllers.pop().remove()

    _refreshSimilarItems: ->
        group = @model.item?.group
        if group? and group isnt Item.Group.Other
            @_similarItemsController.title = "Other #{group}"
            @_similarItemsController.model = @model.findSimilarItems()
        else
            @_similarItemsController.model = null

    _refreshUsedAsToolToMake: ->
        @_usedAsToolToMakeController.title = 'Used as Tool to Make'
        @_usedAsToolToMakeController.model = @model.findToolForRecipes()

    _refreshUsedToMake: ->
        @_usedToMakeController.title = 'Used to Make'
        @_usedToMakeController.model = @model.findComponentInItems()

    _refreshVideos: ->
        @_videoControllers ?= []
        index = 0

        videos = @model?.item?.videos or []
        if videos? and videos.length > 0
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

            @show @$videosSection
        else
            @hide @$videosSection

        while @_videoControllers.length > index
            @_videoControllers.pop().remove()

    _resolveItemSlug: ->
        return if @model.item?

        item = @modPack.findItem @_itemSlug, includeDisabled:true
        if item?
            if not ItemSlug.equal item.slug, @_itemSlug
                router.navigate Url.item(modSlug:item.slug.mod, itemSlug:item.slug.item), trigger:true
                return

            @model.item = item
            item.fetch()
            item.on Event.sync, => @refresh()
