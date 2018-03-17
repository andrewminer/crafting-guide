#
# Crafting Guide - mod_page_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Item}                       = require("crafting-guide-common").deprecated.game
ItemGroupController          = require "../common/item_group/item_group_controller"
{Mod}                        = require("crafting-guide-common").deprecated.game
ModVersionSelectorController = require "../common/mod_version_selector/mod_version_selector_controller"
PageController               = require "../page_controller"
TutorialController           = require "./tutorial/tutorial_controller"
VideoController              = require "../common/video/video_controller"

########################################################################################################################

module.exports = class ModPageController extends PageController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        options.templateName = 'mod_page'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router

    # PageController Overrides #####################################################################

    getBreadcrumbs: ->
        return [
            $('<a href="/browse">Browse</a>')
            $("<b>#{@model.displayName}</b>")
        ]

    getTitle: ->
        return @model.displayName

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @modVersionSelector = @addChild ModVersionSelectorController, '.view__mod_version_selector', model:@model

        @$author             = @$('.about .author')
        @$description        = @$('.about .description')
        @$documentationLink  = @$('.about .documentation')
        @$downloadLink       = @$('.about .download')
        @$homePageLink       = @$('.about .homePage')
        @$itemGroups         = @$(".itemGroups")
        @$logo               = @$('.about img')
        @$title              = @$('.about .title')
        @$tutorialsContainer = @$('section.tutorials .panel')
        @$tutorialsSection   = @$('section.tutorials')
        @$videosContainer    = @$('section.videos .panel')
        @$videosSection      = @$('section.videos')
        @$videosSectionTitle = @$('section.videos h2')
        super

    refresh: ->
        @_refreshAboutBlock()
        @_refreshItemGroups()
        @_refreshTutorials()
        @_refreshVideos()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .about .right a':  'routeLinkClick'

    # Private Methods ##############################################################################

    _refreshAboutBlock: ->
        if @model?
            @$author.text @model.author
            @$description.text @model.description
            @$documentationLink.attr 'href', @model.documentationUrl
            @$downloadLink.attr 'href', @model.downloadUrl
            @$homePageLink.attr 'href', @model.homePageUrl
            @$logo.attr 'src', c.url.modIcon modId:@model.id
            @$title.text @model.displayName
        else
            @$author.text ''
            @$description.text ''
            @$documentationLink.attr 'href', ''
            @$downloadLink.attr 'href', ''
            @$homePageLink.attr 'href', ''
            @$logo.attr 'src', ''
            @$title.text ''

    _refreshItemGroups: ->
        @_groupControllers ?= []
        groupIndex = 0

        for groupName, items of @model.itemGroups
            controller = @_groupControllers[groupIndex]
            if not controller?
                controller = new ItemGroupController
                    imageLoader: @_imageLoader
                    model:       items
                    modPack:     @_modPack
                    router:      @_router
                    title:       groupName

                @_groupControllers.push controller
                @$itemGroups.append controller.$el
                controller.render()
            else
                controller.model = items
                controller.refresh()
            groupIndex++

        while @_groupControllers.length > groupIndex + 1
            @_groupControllers.pop().remove()

    _refreshTutorials: ->
        @_tutorialControllers ?= []
        index                  = 0
        tutorials              = @model.tutorials

        if tutorials.length > 0
            for tutorial in tutorials
                controller = @_tutorialControllers[index]
                if not controller?
                    controller = new TutorialController model: tutorial, router: @_router
                    @_tutorialControllers.push controller
                    @$tutorialsContainer.append controller.$el
                    controller.render()
                else
                    controller.model = tutorial

                index += 1

            while @_tutorialControllers.length > index
                @_tutorialControllers.pop().remove()

            @show @$tutorialsSection
        else
            @hide @$tutorialsSection

    _refreshVideos: ->
        @_videoControllers ?= []
        index = 0

        videos = @model?.videos or []
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
