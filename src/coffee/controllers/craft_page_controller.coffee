###
Crafting Guide - craft_page_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

AdsenseController   = require './adsense_controller'
CraftPage           = require '../models/craft_page'
InventoryController = require './inventory_controller'
PageController      = require './page_controller'
StepController      = require './step_controller'
{Event}             = require '../constants'
{Url}               = require '../constants'

########################################################################################################################

module.exports = class CraftPageController extends PageController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.storage? then throw new Error 'options.storage is required'

        options.model ?= new CraftPage modPack:options.modPack
        options.templateName = 'craft_page'
        super options

        @imageLoader = options.imageLoader
        @modPack     = options.modPack
        @storage     = options.storage

        @model.plan.on Event.change, => @refresh()

    # Event Methods ################################################################################

    onCraftTool: (itemSlug)->
        # TODO: implement this

    onHaveInventoryChanged: ->
        @storage.store 'crafting-plan:have', @model.plan.have.unparse()

    onMoveNeedToHave: (itemSlug)->
        quantity = @model.plan.need.quantityOf itemSlug
        @model.plan.have.add itemSlug, quantity
        @onHaveInventoryChanged()

    onRemoveFromHaveInventory: (itemSlug)->
        @model.plan.have.remove itemSlug
        @onHaveInventoryChanged()

    onRemoveFromWant: (itemSlug)->
        @model.plan.want.remove itemSlug
        @onWantInventoryChange()

    onStopUsingTool: (itemSlug)->
        # TODO: implement this

    onStepComplete: (stepController)->
        step = stepController.model
        for stack in step.recipe.output
            @model.plan.have.add stack.itemSlug, stack.quantity * step.multiplier
        @onHaveInventoryChanged()

    onWantInventoryChange: ->
        text = @model.plan.want.unparse()
        url = Url.crafting inventoryText:text
        router.navigate url

        if @model.plan.want.isEmpty
            @model.plan.have.clear()
            @onHaveInventoryChanged()

    # PageController Overrides #####################################################################

    getTitle: ->
        return 'Craft'

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'

        @wantInventoryController = @addChild InventoryController, '.want .view__inventory',
            imageLoader:     @imageLoader
            isAcceptable:    (item)=> item.isCraftable
            model:           @model.plan.want
            modPack:         @modPack
            firstButtonType: 'remove'
        @wantInventoryController.on Event.button.first, (c, s)=> @onRemoveFromWant(s)
        @wantInventoryController.on Event.change, (c)=> @onWantInventoryChange()

        # @toolsInUseController = @addChild InventoryController, '.tools .view__inventory',
        #     imageLoader:      @imageLoader
        #     model:            @model.plan.toolsInUse
        #     modPack:          @modPack
        #     firstButtonType:  'down'
        #     secondButtonType: 'up'
        # @toolsInUseController.on Event.button.first, (c, s)=> @onStopUsingTool(s)
        # @toolsInUseController.of Event.button.second, (c, s)=> @onCraftTool(s)

        @haveInventoryController = @addChild InventoryController, '.have .view__inventory',
            imageLoader:     @imageLoader
            model:           @model.plan.have
            modPack:         @modPack
            firstButtonType: 'down'
        @haveInventoryController.on Event.button.first, (c, s)=>
            @onRemoveFromHaveInventory(s)
        @haveInventoryController.on Event.change, (c)=> @onHaveInventoryChanged()

        @needInventoryController = @addChild InventoryController, '.need .view__inventory',
            editable:        false
            imageLoader:     @imageLoader
            model:           @model.plan.need
            modPack:         @modPack
            firstButtonType: 'up'
        @needInventoryController.on Event.button.first, (c, s)=> @onMoveNeedToHave(s)

        @$instructionsSection = @$('.instructions.section')
        @$makeSection         = @$('.make.section')
        @$toolsSection        = @$('.tools.section')
        @$ingredientsSection  = @$('.ingredients.section')
        @$stepsSection        = @$('.steps.section')
        @$stepsContainer      = @$('.steps.section .panel')

        super

    onWillRender: ->
        @model.plan.have.clear()
        @model.plan.have.parse @storage.load('crafting-plan:have')
        super

    refresh: ->
        @_refreshSectionVisibility()
        @_refreshSteps()
        @adsenseController.fillAdPositions()
        super

    # Backbone.View Overrides ########################################################################

    events: ->
        return _.extend super,
            'click .instructions a': 'routeLinkClick'

    # Private Methods ################################################################################

    _isStepCompletable: (controller)->
        return not @model.plan.want.hasAtLeast controller.model.outputItemSlug

    _refreshSectionVisibility: ->
        if @model.plan.want.isEmpty
            for $el in [@$toolsSection, @$ingredientsSection, @$stepsSection]
                @hide $el
            @show @$instructionsSection
        else
            for $el in [@$toolsSection, @$ingredientsSection, @$stepsSection]
                @show $el
            @hide @$instructionsSection

    _refreshSteps: ->
        @_stepControllers ?= []
        index = 0

        for step in @model.plan.steps
            controller = @_stepControllers[index]
            if not controller?
                controller = new StepController
                    canComplete: (controller)=> @_isStepCompletable(controller)
                    imageLoader: @imageLoader
                    model:       step
                    modPack:     @modPack
                controller.on Event.button.complete, (c)=> @onStepComplete(c)
                controller.render()

                @$stepsContainer.append controller.$el
                @_stepControllers.push controller
            else
                controller.model = step

            index += 1

        while @_stepControllers.length > index
            @_stepControllers.pop().remove()
