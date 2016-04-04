#
# Crafting Guide - craft_page_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

AdsenseController          = require '../common/adsense/adsense_controller'
BaseController             = require '../base_controller'
CraftPage                  = require '../../models/site/craft_page'
Craftsman                  = require '../../models/crafting/craftsman'
CraftsmanWorkingController = require './craftsman_working/craftsman_working_controller'
InventoryController        = require '../common/inventory/inventory_controller'
PageController             = require '../page_controller'
StepController             = require './step/step_controller'

########################################################################################################################

module.exports = class CraftPageController extends PageController

    constructor: (options={})->
        if not options.imageLoader? then throw new Error 'options.imageLoader is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        if not options.router? then throw new Error 'options.router is required'
        if not options.storage? then throw new Error 'options.storage is required'

        options.model ?= new CraftPage modPack:options.modPack
        options.templateName = 'craft_page'
        super options

        @_imageLoader = options.imageLoader
        @_modPack     = options.modPack
        @_router      = options.router
        @_storage     = options.storage

    # c.event Methods ################################################################################

    onHaveInventoryChanged: ->
        logger.warning => "storing have: #{@model.craftsman.have.unparse()}"
        @_storage.store 'crafting-plan:have', @model.craftsman.have.unparse()

    onMoveNeedToHave: (itemSlug)->
        quantity = @_needInventoryController.model.quantityOf itemSlug
        @model.craftsman.have.add itemSlug, quantity

    onRemoveFromHaveInventory: (itemSlug)->
        @model.craftsman.have.remove itemSlug

    onRemoveFromWant: (itemSlug)->
        @model.craftsman.want.remove itemSlug
        @onWantInventoryChanged()

    onWantInventoryChanged: ->
        text = @model.craftsman.want.unparse()
        url = c.url.crafting inventoryText:text
        @router.navigate url

        if @model.craftsman.want.isEmpty
            @model.craftsman.have.clear()

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return c.text.craftDescription()

    getTitle: ->
        return 'Craft'

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_adsenseController = @addChild AdsenseController, '.view__adsense', model:'skyscraper'

        @_wantInventoryController = @addChild InventoryController, '.want .view__inventory',
            firstButtonType: 'remove'
            imageLoader:     @_imageLoader
            isAcceptable:    (item)=> item.isCraftable
            modPack:         @_modPack
            model:           @model.craftsman.want
            router:          @_router
        @_wantInventoryController.on c.event.button.first, (c, s)=> @onRemoveFromWant(s)
        @_wantInventoryController.on c.event.change, (c)=> @onWantInventoryChanged()

        @_haveInventoryController = @addChild InventoryController, '.have .view__inventory',
            firstButtonType: 'down'
            imageLoader:     @_imageLoader
            modPack:         @_modPack
            model:           @model.craftsman.have
            router:          @_router
        @_haveInventoryController.on c.event.button.first, (controller, itemSlug)=>
            @onRemoveFromHaveInventory itemSlug
        @_haveInventoryController.on c.event.change, (c)=> @onHaveInventoryChanged()

        @_needInventoryController = @addChild InventoryController, '.need .view__inventory',
            editable:        false
            firstButtonType: 'up'
            imageLoader:     @_imageLoader
            modPack:         @_modPack
            model:           null
            router:          @_router
        @_needInventoryController.on c.event.button.first, (c, s)=> @onMoveNeedToHave(s)

        @_workingSectionController = @addChild CraftsmanWorkingController, '.view__craftsman_working',
            model: @model.craftsman

        @$haveSection         = @$('section.have')
        @$instructionsSection = @$('section.instructions')
        @$makeSection         = @$('section.make')
        @$needSection         = @$('section.need')
        @$stepsContainer      = @$('section.steps .panel')
        @$stepsSection        = @$('section.steps')
        @$toolsSection        = @$('section.tools')
        @$workingSection      = @$('.view__craftsman_working')

        super

    onWillRender: ->
        @model.craftsman.have.clear()
        @model.craftsman.have.parse @_storage.load('crafting-plan:have')
        super

    refresh: ->
        @_needInventoryController.model = @model.craftsman.plan?.need
        @_refreshSectionVisibility()
        @_refreshSteps()
        @_adsenseController.fillAdPositions()
        super

    # Backbone.View Overrides ########################################################################

    events: ->
        return _.extend super,
            'click .instructions a': 'routeLinkClick'

    # Private Methods ################################################################################

    _addTools: (controller)->
        controller.model.addToolsTo @model.craftsman.want

    _completeStep: (controller)->
        controller.model.completeInto @model.craftsman.have

    _isAddingToolsPossible: (controller)->
        tools = controller.model.recipe.tools
        return false unless tools.length > 0

        have = @model.craftsman.have
        want = @model.craftsman.want

        for stack in tools
            return false if have.hasAtLeast stack.itemSlug
            return false if want.hasAtLeast stack.itemSlug

        return true

    _isStepCompletable: (controller)->
        recipe = controller.model.recipe
        for stack in recipe.output
            return false if @model.craftsman.want.hasAtLeast stack.itemSlug

        return true

    _refreshSectionVisibility: ->
        return unless @_rendered

        allSections = [
            @$instructionsSection, @$haveSection, @$needSection, @$stepsSection, @$toolsSection, @$workingSection
        ]

        visibleSections = []

        if @model.craftsman.want.isEmpty
            visibleSections.push el for el in [@$instructionsSection, @$wantSection]
        else if @model.craftsman.stage is Craftsman::STAGE.INVALID
            visibleSections.push el for el in [@$wantSection, @$workingSection]
        else if not @model.craftsman.complete
            visibleSections.push el for el in [@$wantSection, @$workingSection]
        else
            visibleSections.push el for el in [@$haveSection, @$needSection, @$stepsSection, @$wantSection]

        @hide $el for $el in allSections
        @show $el for $el in visibleSections

    _refreshSteps: ->
        steps = @model.craftsman.plan?.steps or []
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
                controller.render()

                @$stepsContainer.append controller.$el
                @_stepControllers.push controller
            else
                controller.model = step

            index += 1

        while @_stepControllers.length > index
            @_stepControllers.pop().remove()
