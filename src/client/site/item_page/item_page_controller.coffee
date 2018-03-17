#
# Crafting Guide - item_page_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

EditableFile              = require "../../models/site/editable_file"
{Item}                    = require("crafting-guide-common").models
{ItemDetail}              = require("crafting-guide-common").models
{ItemDetailJsonParser}    = require("crafting-guide-common").parsing
ItemDisplay               = require "../../models/site/item_display"
ItemGroupController       = require "../common/item_group/item_group_controller"
ItemPage                  = require "../../models/site/item_page"
MarkdownSectionController = require "../common/markdown_section/markdown_section_controller"
PageController            = require "../page_controller"
RecipeController          = require "../common/recipe/recipe_controller"
RecipeDisplay             = require "../../models/site/recipe_display"
VideoController           = require "../common/video/video_controller"
w                         = require "when"

########################################################################################################################

module.exports = class ItemPageController extends PageController

    @::FILE_UPLOAD_DELAY = 250

    constructor: (options={})->
        if not options.model?.constructor is ItemPage then throw new Error "options.model must be an ItemPage instance"
        if not options.client? then throw new Error "options.client is required"
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"

        options.templateName ?= "item_page"
        super options

        @_client          = options.client
        @_descriptionFile = null
        @_enterFeedback   = options.enterFeedback
        @_imageLoader     = options.imageLoader
        @_modPack         = options.modPack
        @_router          = options.router
        @_triggerEditing  = options.login

    # Event Methods ################################################################################

    craftingPlanButtonClicked: ->
        tracker.trackEvent c.tracking.category.craft, "view-crafting-plan", @model.item.slug
        @_router.navigate @model.itemDisplay.craftingUrl, trigger:true
        return false

    # PageController Overrides #####################################################################

    getBreadcrumbs: ->
        return [
            $("<a href=\"/browse\">Browse</a>")
            $("<a href=\"#{@model.itemDisplay.modUrl}\">#{@model.itemDisplay.mod.displayName}</a>")
            $("<b>#{@model.itemDisplay.name}</b>")
        ]

    getExtraNav: ->
        item = @_modPack.chooseRandomItem()
        return null unless item?

        display = new ItemDisplay item
        return $("<a href=\"#{display.url}\">Random Item</a>")

    getMetaDescription: ->
        data = itemName:@model.item.displayName, modName:@model.item.mod.displayName
        return c.text.itemDescription data

    getTitle: ->
        return "#{@model.item.displayName} from #{@model.item.mod.displayName}"

    # BaseController Overrides #####################################################################

    onDidModelChange: ->
        @trigger c.event.change
        super

    onDidRender: ->
        options                      = imageLoader:@_imageLoader, modPack:@_modPack, router:@_router, show:false
        @_similarItemsController     = @addChild ItemGroupController, ".view__item_group.similar", options
        @_usedAsToolToMakeController = @addChild ItemGroupController, ".view__item_group.usedAsToolToMake ", options
        @_usedToMakeController       = @addChild ItemGroupController, ".view__item_group.usedToMake", options

        @_descriptionController = @addChild MarkdownSectionController, ".view__markdown_section",
            client:        @_client
            editable:      true
            modPack:       @_modPack
            router:        @_router
            beginEditing:  => @_beginEditingDescription()
            endEditing:    => @_endEditingDescription()
            enterFeedback: @_enterFeedback

        @$aboutImage         = @$(".about img")
        @$craftingPlanButton = @$(".button.craftingPlan")
        @$name               = @$(".about .title")
        @$officialLink       = @$(".about a.officialLink")
        @$sourceModLink      = @$(".about a.sourceMod")
        @$aboutLinks         = @$(".about .right")

        @$multiblockSection       = @$("section.multiblock")
        @$recipeContainer         = @$("section.recipes .panel")
        @$recipesSection          = @$("section.recipes")
        @$recipesSectionTitle     = @$("section.recipes h2")
        @$similarSection          = @$("section.similar")
        @$usedAsToolToMakeSection = @$("section.usedAsToolToMake")
        @$usedToMakeSection       = @$("section.usedToMake")
        @$videosContainer         = @$("section.videos .panel")
        @$videosSection           = @$("section.videos")
        @$videosSectionTitle      = @$("section.videos h2")
        super

    refresh: ->
        if @model.item?
            @_imageLoader.load @model.itemDisplay.iconUrl, @$aboutImage
            @$name.text @model.itemDisplay.name

            @_descriptionController.imageBase = c.url.itemImageDir @model.itemDisplay

            if @model.item.detail?.links.length > 0
                @$officialLink.attr "href", @model.item.detail.links[0]
                @show @$aboutLinks
            else
                @hide @$aboutLinks

            if @model.item.isCraftable
                @show @$craftingPlanButton
            else
                @hide @$craftingPlanButton

            if @_triggerEditing
                @_triggerEditing = false
                @_descriptionController.onEditClicked {}

            @show()
        else
            @hide()

        @_refreshSourceMod()
        @_refreshDescription()
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
            "click a.craftingPlan":       "routeLinkClick"
            "click a.sourceMod":          "routeLinkClick"
            "click .markdown a":          "routeLinkClick"
            "click .button.craftingPlan": "craftingPlanButtonClicked"

    # Private Methods ##############################################################################

    _beginEditingDescription: ->
        if not @user?
            global.site.login()
            return w.reject new Error "must be logged in to edit"

        if not @model.item?
            return w.reject new Error "must have an item"

        pathArgs = modSlug:@model.item.mod.id, itemSlug:@model.itemDisplay.itemSlug
        attributes =
            fileName: c.gitHub.file.itemDescription.fileName pathArgs
            path:     c.gitHub.file.itemDescription.path pathArgs

        @_descriptionFile = new EditableFile attributes, client:@_client
        @_descriptionFile.fetch()
            .then =>
                if @_descriptionFile.encodedData?.length > 0
                    parser = new ItemDetailJsonParser item:@model.item
                    parser.parse @_descriptionFile.getDecodedData "utf8"
                else
                    @model.item.detail = new ItemDetail item:@model.item

                @_descriptionController.model = @model.item.detail.description

    _endEditingDescription: ->
        oldDescription = @model.item.detail.description
        promises = []

        saveList = []
        for imageFile in @_descriptionController.imageFiles
            saveList.push
                file:    imageFile
                message: "User-submitted image for #{@model.item.displayName} from #{global.hostName}"

        @model.item.detail.description = @_descriptionController.model
        parser = new ItemDetailJsonParser item:@model.item
        @_descriptionFile.setDecodedData parser.format @model.item.detail
        saveList.push
            file:    @_descriptionFile
            message: "User-submitted text for #{@model.item.displayName} from #{global.hostName}"

        saveNextFile = (fileList)->
            return w(true) if fileList.length is 0
            {file, message} = fileList.shift()
            file.save message
                .delay @FILE_UPLOAD_DELAY
                .then ->
                    saveNextFile fileList

        saveNextFile saveList
            .catch (e)=>
                @model.item.detail.description = oldDescription
                throw e

    _refreshDescription: ->
        if @model.item.detail?.description.length > 0
            @_descriptionController.model = @model.item.detail.description
            @_descriptionController.resetToDefaultState()

    _refreshRecipes: ->
        @_recipeControllers ?= []
        index = 0

        recipes = @model.findRecipes()
        if recipes?.length > 0
            @$recipesSectionTitle.html if recipes.length is 1 then "Recipe" else "Recipes"

            for recipe in recipes
                controller = @_recipeControllers[index]
                model = new RecipeDisplay
                    recipe:              recipe
                    showInputInventory:  true
                    showOutputInventory: true
                if not controller?
                    controller = new RecipeController
                        imageLoader: @_imageLoader
                        modPack:     @_modPack
                        model:       model
                        router:      @_router
                    @_recipeControllers.push controller
                    @$recipeContainer.append controller.$el
                    controller.render()
                else
                    controller.model = model
                index++

            @show @$recipesSection
        else
            @hide @$recipesSection

        while @_recipeControllers.length > index
            @_recipeControllers.pop().remove()

    _refreshSimilarItems: ->
        groupName = @model.item.groupName
        if groupName? and groupName isnt Item::DEFAULT_GROUP_NAME
            @_similarItemsController.title = "Other #{groupName}"
            @_similarItemsController.model = @model.findSimilarItems()
        else
            @_similarItemsController.model = null

    _refreshSourceMod: ->
        mod = @model.item.mod
        @$sourceModLink.attr "href", c.url.mod @model.itemDisplay
        @$sourceModLink.text mod.name
        @show @$sourceModLink

    _refreshUsedAsToolToMake: ->
        @_usedAsToolToMakeController.title = "Used as Tool to Make"
        @_usedAsToolToMakeController.model = @model.findToolForItems()

    _refreshUsedToMake: ->
        @_usedToMakeController.title = "Used to Make"
        @_usedToMakeController.model = @model.findComponentInItems()

    _refreshVideos: ->
        @_videoControllers ?= []
        index = 0

        videos = @model.item.detail?.videos
        if videos? and videos.length > 0
            @$videosSectionTitle.html if videos.length is 1 then "Video" else "Videos"

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

