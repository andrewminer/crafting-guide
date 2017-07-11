#
# Crafting Guide - craft_page_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

CraftPage              = require "../../models/site/craft_page"
WorkingPanelController = require "./working_panel/working_panel_controller"
{Inventory}            = require("crafting-guide-common").models
InventoryController    = require "../common/inventory/inventory_controller"
{Observable}           = require("crafting-guide-common").util
PageController         = require "../page_controller"
StepController         = require "./step/step_controller"

########################################################################################################################

module.exports = class CraftPageController extends PageController

    @::SCROLL_BUFFER = 8 # px
    @::STEP_RENDER_DELAY = 25 # ms

    constructor: (options={})->
        if not options.imageLoader? then throw new Error "options.imageLoader is required"
        if not options.modPack? then throw new Error "options.modPack is required"
        if not options.router? then throw new Error "options.router is required"
        if not options.storage? then throw new Error "options.storage is required"

        options.model ?= new CraftPage modPack:options.modPack, params:options.params
        options.templateName = 'craft_page'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router
        @_storage     = options.storage

        @model.have.on Observable::ANY, this, "onHaveInventoryChanged"
        @model.want.on Observable::ANY, this, "onWantInventoryChanged"

    # Event Methods ################################################################################

    onHaveInventoryChanged: ->
        @_storage.store 'crafting-plan:have', @model.have.toUrlString()

    onMoveNeedToHave: (item)->
        quantity = @_needInventoryController.model.getQuantity item
        @model.have.add item, quantity

    onRemoveFromHave: (item)->
        @model.have.remove item

    onRemoveFromWant: (item)->
        @model.want.remove item

    onSampleClicked: (event)->
        $el = $(event.target)
        while $el.length > 0
            inventoryText = $el.attr "data-slug"
            break if inventoryText
            $el = $el.parent()

        if inventoryText?
            try
                tracker.trackEvent c.tracking.category.craft, "add-sample", inventoryText
                sampleInventory = Inventory.fromUrlString inventoryText, @_modPack
                @model.want.merge sampleInventory
                @_scrollTo @$workingSection
            catch e
                logger.error e

        return false

    onWantInventoryChanged: ->
        text = @model.want.toUrlString()
        url = c.url.crafting inventoryText:text
        @router.navigate url

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return c.text.craftDescription()

    getTitle: ->
        description = @model.want.toDescription()
        return null unless description?
        return "Crafting Plan for #{description}"

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_wantInventoryController = @addChild InventoryController, '.want .view__inventory',
            firstButtonType: 'remove'
            imageLoader:     @_imageLoader
            isAcceptable:    (item)=> item.isCraftable
            modPack:         @_modPack
            model:           @model.want
            router:          @_router
            trackingContext: c.tracking.category.craftWant
        @_wantInventoryController.on c.event.button.first, (controller, item)=> @onRemoveFromWant item

        @_haveInventoryController = @addChild InventoryController, '.have .view__inventory',
            firstButtonType: 'down'
            imageLoader:     @_imageLoader
            modPack:         @_modPack
            model:           @model.have
            router:          @_router
            trackingContext: c.tracking.category.craftHave
        @_haveInventoryController.on c.event.button.first, (controller, item)=> @onRemoveFromHave item

        @_needInventoryController = @addChild InventoryController, '.need .view__inventory',
            editable:        false
            firstButtonType: 'up'
            imageLoader:     @_imageLoader
            modPack:         @_modPack
            model:           null
            router:          @_router
            trackingContext: c.tracking.category.craftNeed
        @_needInventoryController.on c.event.button.first, (controller, item)=> @onMoveNeedToHave item

        @_workingPanelController = @addChild WorkingPanelController, '.view__working_panel', model:@model

        @$haveSection         = @$('section.have')
        @$instructionsSection = @$('section.instructions')
        @$makeSection         = @$('section.make')
        @$needSection         = @$('section.need')
        @$stepsContainer      = @$('section.steps .panel')
        @$stepsSection        = @$('section.steps')
        @$toolsSection        = @$('section.tools')
        @$workingSection      = @$('.view__working_panel')

        if c.screen.type.compute() is c.screen.type.mobile
            @$('.view__inventory.large').removeClass 'large'

        super

    onWillRender: ->
        @model.have.clear()
        @model.have.merge Inventory.fromUrlString @_storage.load('crafting-plan:have')
        @model.have.on Observable::ANY, this, "onHaveInventoryChanged"
        @model.want.on Observable::ANY, this, "tryRefresh"

        super

    refresh: ->
        @_needInventoryController.model = @model.currentPlan?.need
        @_refreshOutdated()
        @_refreshSectionVisibility()
        @_refreshSteps()

        super

    # Backbone.View Overrides ########################################################################

    events: ->
        return _.extend super,
            'click .instructions a': 'onSampleClicked'

    # Private Methods ################################################################################

    _addTools: (controller)->
        controller.model.addToolsTo @model.want

    _completeStep: (controller)->
        controller.markComplete @model.have

    _isAddingToolsPossible: (controller)->
        tools = (item for itemId, item of controller.model.recipe.tools)
        return false unless tools.length > 0

        have = @model.have
        want = @model.want

        for item in tools
            return false if @model.have.contains item
            return false if @model.want.contains item

        return true

    _isStepCompletable: (controller)->
        userWantsItem = @model.want.contains controller.model.recipe.output.item
        return not userWantsItem

    _refreshOutdated: ->
        if @model.isOutdated
            @$el.addClass 'outdated'
        else
            @$el.removeClass 'outdated'

    _refreshSectionVisibility: ->
        return unless @_rendered

        allSections = [
            @$instructionsSection, @$haveSection, @$needSection, @$stepsSection, @$toolsSection, @$workingSection
        ]

        visibleSections = []

        # TODO: Figure out what to do if the planner can't make a valid plan
        # else if @model.craftsman.stage is Craftsman::STAGE.INVALID
        #     visibleSections.push el for el in [@$wantSection, @$haveSection, @$workingSection]
        # TODO: Play around and see if the algo ever takes too long
        # else if not @model.craftsman.complete
        #     visibleSections.push el for el in [@$wantSection, @$haveSection, @$workingSection]

        if @model.want.isEmpty
            visibleSections.push el for el in [@$instructionsSection, @$wantSection]
        else
            visibleSections.push el for el in [@$haveSection, @$wantSection, @$workingSection]
            if @model.currentPlan?
                visibleSections.push el for el in [@$needSection, @$stepsSection]

        @hide $el for $el in allSections
        @show $el for $el in visibleSections

    _refreshSteps: ->
        steps = @model.currentPlan?.steps or []
        @_stepControllers ?= []
        index = 0

        for step in steps
            controller = @_stepControllers[index]
            if not controller?
                controller = new StepController
                    canAddTools: (controller)=> @_isAddingToolsPossible controller
                    canComplete: (controller)=> @_isStepCompletable controller
                    onComplete:  (controller)=> @_completeStep controller
                    onAddTools:  (controller)=> @_addTools controller
                    imageLoader: @_imageLoader
                    model:       step
                    modPack:     @_modPack
                    router:      @_router

                do (controller, index)=>
                    _.delay (=>
                        controller.render()

                        @$stepsContainer.append controller.$el
                        @_stepControllers.push controller
                    ), (index * @STEP_RENDER_DELAY)
            else
                controller.model = step

            index += 1

        while @_stepControllers.length > index
            @_stepControllers.pop().remove()

    _scrollTo: ($targetEl)->
        @_$scrollTarget = $targetEl

        if @_scrollTimer?
            clearTimeout @_scrollTimer

        @_scrollTimer = setTimeout(=>
            $el = @_$scrollTarget
            @_scrollTimer = null

            minScrollPosition = $el.offset().top + $el.height() - $(window).height() - @SCROLL_BUFFER
            maxScrollPosition = $el.offset().top + @SCROLL_BUFFER
            scrollPosition = $(window).scrollTop()

            scrollTarget = scrollPosition
            if scrollPosition > maxScrollPosition
                scrollTarget = maxScrollPosition
            else if scrollPosition < minScrollPosition
                scrollTarget = minScrollPosition
            else
                return

            $('html, body').animate {scrollTop:scrollTarget}, c.duration.normal
        , c.duration.slow)
