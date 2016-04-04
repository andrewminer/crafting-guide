#
# Crafting Guide - item_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

AdsenseController          = require '../common/adsense/adsense_controller'
EditableFile               = require '../../models/site/editable_file'
Item                       = require '../../models/game/item'
ItemGroupController        = require '../common/item_group/item_group_controller'
ItemPage                   = require '../../models/site/item_page'
ItemSlug                   = require '../../models/game/item_slug'
MarkdownSectionController  = require '../common/markdown_section/markdown_section_controller'
MultiblockViewerController = require './multiblock_viewer/multiblock_viewer_controller'
PageController             = require '../page_controller'
RecipeDetailController     = require './recipe_detail/recipe_detail_controller'
VideoController            = require '../common/video/video_controller'

########################################################################################################################

module.exports = class ItemPageController extends PageController

    @::FILE_UPLOAD_DELAY = 250

    constructor: (options={})->
        if not options.client? then throw new Error 'options.client is required'
        if not options.itemSlug? then throw new Error 'options.itemSlug is required'
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'

        options.model        ?= new ItemPage modPack:options.modPack
        options.templateName ?= 'item_page'

        super options

        @_client          = options.client
        @_descriptionFile = null
        @_enterFeedback   = options.enterFeedback
        @_imageLoader     = options.imageLoader
        @_itemSlug        = options.itemSlug
        @_modPack         = options.modPack
        @_router          = options.router

        @_modPack.on c.event.change, =>
            @tryRefresh()
            @trigger c.event.change

    # Event Methods ################################################################################

    craftingPlanButtonClicked: ->
        display = @_modPack.findItemDisplay @model.item.slug
        @_router.navigate display.craftingUrl, trigger:true
        return false

    # PageController Overrides #####################################################################

    getBreadcrumbs: ->
        return [] unless @_itemSlug?

        display = @_modPack.findItemDisplay @_itemSlug
        return [] unless display.itemName? and display.modName

        return [
            $("<a href='/browse'>Browse</a>")
            $("<a href='#{c.url.mod modSlug:display.modSlug}'>#{display.modName}</a>")
            $("<b>#{display.itemName}</b>")
        ]

    getMetaDescription: ->
        return null unless @_itemSlug?
        display = @_modPack.findItemDisplay @_itemSlug
        return c.text.itemDescription display

    getTitle: ->
        return null unless @_itemSlug?

        display = @_modPack.findItemDisplay @_itemSlug
        return null unless display.itemName? and display.modName?

        return "#{display.itemName} from #{display.modName}"

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_adsenseController = @addChild AdsenseController, '.view__adsense', model:'skyscraper', router: @_router

        options                      = imageLoader:@_imageLoader, modPack:@_modPack, router:@_router, show:false
        @_multiblockController       = @addChild MultiblockViewerController, '.view__multiblock_viewer', options
        @_similarItemsController     = @addChild ItemGroupController, '.view__item_group.similar', options
        @_usedAsToolToMakeController = @addChild ItemGroupController, '.view__item_group.usedAsToolToMake ', options
        @_usedToMakeController       = @addChild ItemGroupController, '.view__item_group.usedToMake', options

        @_descriptionController = @addChild MarkdownSectionController, '.view__markdown_section',
            client:        @_client
            editable:      true
            modPack:       @_modPack
            router:        @_router
            beginEditing:  => @_beginEditingDescription()
            endEditing:    => @_endEditingDescription()
            enterFeedback: @_enterFeedback

        @$aboutImage    = @$('.about img')
        @$name          = @$('.about .title')
        @$officialLink  = @$('.about a.officialLink')
        @$sourceModLink = @$('.about a.sourceMod')
        @$aboutLinks    = @$('.about .right')

        @$multiblockSection       = @$('section.multiblock')
        @$recipeContainer         = @$('section.recipes .panel')
        @$recipesSection          = @$('section.recipes')
        @$recipesSectionTitle     = @$('section.recipes h2')
        @$similarSection          = @$('section.similar')
        @$usedAsToolToMakeSection = @$('section.usedAsToolToMake')
        @$usedToMakeSection       = @$('section.usedToMake')
        @$videosContainer         = @$('section.videos .panel')
        @$videosSection           = @$('section.videos')
        @$videosSectionTitle      = @$('section.videos h2')
        super

    refresh: ->
        @_resolveItemSlug()

        if @model.item?
            display = @_modPack.findItemDisplay @model.item.slug
            @_imageLoader.load display.iconUrl, @$aboutImage
            @$name.text display.itemName

            @_descriptionController.imageBase = c.url.itemImageDir display

            if @model.item.officialUrl?
                @$officialLink.attr 'href', @model.item.officialUrl
                @show @$aboutLinks
            else
                @hide @$aboutLinks

            @show()
        else
            @hide()

        @_refreshSourceMod()
        @_refreshDescription()
        @_refreshMultiblock()
        @_refreshRecipes()
        @_refreshSimilarItems()
        @_refreshUsedAsToolToMake()
        @_refreshUsedToMake()
        @_refreshVideos()

        super

    setUser: (user)->
        super user
        @_descriptionController.user = user if @_descriptionController?

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.craftingPlan':       'routeLinkClick'
            'click a.sourceMod':          'routeLinkClick'
            'click .markdown a':          'routeLinkClick'
            'click .button.craftingPlan': 'craftingPlanButtonClicked'

    # Private Methods ##############################################################################

    _beginEditingDescription: ->
        if not @user?
            global.site.login()
            return w.reject new Error 'must be logged in to edit'

        if not @model.item?
            return w.reject new Error 'must have an item'

        pathArgs = modSlug:@_itemSlug.mod, itemSlug:@_itemSlug.item
        attributes =
            fileName: c.gitHub.file.itemDescription.fileName pathArgs
            path:     c.gitHub.file.itemDescription.path pathArgs

        @_descriptionFile = new EditableFile attributes, client:@_client
        @_descriptionFile.fetch()
            .then =>
                if @_descriptionFile.encodedData?.length > 0
                    @model.item.parse @_descriptionFile.getDecodedData 'utf8'
                else
                    @model.item.description = ''

                @_descriptionController.model = @model.item.description

    _endEditingDescription: ->
        oldDescription = @model.item.description
        promises = []

        saveList = []
        for imageFile in @_descriptionController.imageFiles
            saveList.push
                file:    imageFile
                message: "User-submitted image for #{@model.item.name} from #{global.hostName}"

        @model.item.description = @_descriptionController.model
        @_descriptionFile.setDecodedData @model.item.unparse()
        saveList.push
            file:    @_descriptionFile
            message: "User-submitted text for #{@model.item.name} from #{global.hostName}"

        saveNextFile = (fileList)->
            return w(true) if fileList.length is 0
            {file, message} = fileList.shift()
            file.save message
                .delay @FILE_UPLOAD_DELAY
                .then ->
                    saveNextFile fileList

        saveNextFile saveList
            .catch (e)=>
                @model.item.description = oldDescription
                throw e

    _refreshDescription: ->
        if @model.item?.description?.length > 0
            @_descriptionController.model = @model.item.description
            @_descriptionController.resetToDefaultState()

    _refreshMultiblock: ->
        if @model.item?.multiblock?
            @_multiblockController.model = @model.item.multiblock
            @show @$multiblockSection
        else
            @hide @$multiblockSection

    _refreshRecipes: ->
        @_recipeControllers ?= []
        index = 0

        recipes = @model.findRecipes()
        if recipes?.length > 0
            @$recipesSectionTitle.html if recipes.length is 1 then 'Recipe' else 'Recipes'

            for recipe in @model.findRecipes()
                controller = @_recipeControllers[index]
                if not controller?
                    controller = new RecipeDetailController
                        imageLoader: @_imageLoader
                        modPack:     @_modPack
                        model:       recipe
                        router:      @_router
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

    _refreshSourceMod: ->
        mod = @model.item?.modVersion?.mod
        if mod?.name?.length > 0
            @$sourceModLink.attr 'href', c.url.mod modSlug:mod.slug
            @$sourceModLink.text mod.name

            @show @$sourceModLink
        else
            @hide @$sourceModLink

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

        item = @_modPack.findItem @_itemSlug, includeDisabled:true
        if item?
            if not ItemSlug.equal item.slug, @_itemSlug
                router.navigate c.url.item(modSlug:item.slug.mod, itemSlug:item.slug.item), trigger:true
                return

            @model.item = item
            item.fetch()
            item.on c.event.sync, => @refresh()
