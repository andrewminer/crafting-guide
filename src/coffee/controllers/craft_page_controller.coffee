###
Crafting Guide - craft_page_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

_                          = require 'underscore'
AdsenseController          = require './adsense_controller'
CraftPage                  = require '../models/craft_page'
Craftsman                  = require '../models/crafting/craftsman'
CraftsmanWorkingController = require './craftsman_working_controller'
{Event}                    = require '../constants'
InventoryController        = require './inventory_controller'
PageController             = require './page_controller'
StepController             = require './step_controller'
{Text}                     = require '../constants'
{Url}                      = require '../constants'

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

    # Event Methods ################################################################################

    onHaveInventoryChanged: ->
        @storage.store 'crafting-plan:have', @model.craftsman.have.unparse()

    onMoveNeedToHave: (itemSlug)->
        quantity = @needInventoryController.model.quantityOf itemSlug
        @model.craftsman.have.add itemSlug, quantity
        @onHaveInventoryChanged()

    onRemoveFromHaveInventory: (itemSlug)->
        @model.craftsman.have.remove itemSlug
        @onHaveInventoryChanged()

    onRemoveFromWant: (itemSlug)->
        @model.craftsman.want.remove itemSlug
        @onWantInventoryChange()

    onStepComplete: (stepController)->
        step = stepController.model
        for stack in step.recipe.output
            @model.craftsman.have.add stack.itemSlug, stack.quantity * step.multiplier
        @onHaveInventoryChanged()

    onWantInventoryChange: ->
        text = @model.craftsman.want.unparse()
        url = Url.crafting inventoryText:text
        router.navigate url

        if @model.craftsman.want.isEmpty
            @model.craftsman.have.clear()
            @onHaveInventoryChanged()

    # PageController Overrides #####################################################################

    getMetaDescription: ->
        return Text.craftDescription()

    getTitle: ->
        return 'Craft'

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @adsenseController = @addChild AdsenseController, '.view__adsense', model:'sidebar_skyscraper'

        @wantInventoryController = @addChild InventoryController, '.want .view__inventory',
            imageLoader:     @imageLoader
            isAcceptable:    (item)=> item.isCraftable
            model:           @model.craftsman.want
            modPack:         @modPack
            firstButtonType: 'remove'
        @wantInventoryController.on Event.button.first, (c, s)=> @onRemoveFromWant(s)
        @wantInventoryController.on Event.change, (c)=> @onWantInventoryChange()

        @haveInventoryController = @addChild InventoryController, '.have .view__inventory',
            imageLoader:     @imageLoader
            model:           @model.craftsman.have
            modPack:         @modPack
            firstButtonType: 'down'
        @haveInventoryController.on Event.button.first, (c, s)=>
            @onRemoveFromHaveInventory(s)
        @haveInventoryController.on Event.change, (c)=> @onHaveInventoryChanged()

        @needInventoryController = @addChild InventoryController, '.need .view__inventory',
            editable:        false
            imageLoader:     @imageLoader
            model:           null
            modPack:         @modPack
            firstButtonType: 'up'
        @needInventoryController.on Event.button.first, (c, s)=> @onMoveNeedToHave(s)

        @workingSectionController = @addChild CraftsmanWorkingController, '.view__craftsman_working',
            model: @model.craftsman

        @$haveSection         = @$('.have.section')
        @$instructionsSection = @$('.instructions.section')
        @$makeSection         = @$('.make.section')
        @$needSection         = @$('.need.section')
        @$stepsContainer      = @$('.steps.section .panel')
        @$stepsSection        = @$('.steps.section')
        @$toolsSection        = @$('.tools.section')
        @$workingSection      = @$('.view__craftsman_working')

        super

    onWillRender: ->
        @model.craftsman.have.clear()
        @model.craftsman.have.parse @storage.load('crafting-plan:have')
        super

    refresh: ->
        @needInventoryController.model = @model.craftsman.plan?.need
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
        return not @model.craftsman.want.hasAtLeast controller.model.outputItemSlug

    _refreshSectionVisibility: ->
        return unless @_rendered

        toShow = []
        toHide = []

        if @model.craftsman.want.isEmpty
            toShow.push el for el in [@$instructionsSection]
            toHide.push el for el in [@$toolsSection, @$needSection, @$stepsSection, @$workingSection]
        else if @model.craftsman.stage is Craftsman::STAGE.INVALID
            toShow.push el for el in [@$workingSection]
            toHide.push el for el in [@$instructionsSection, @$toolsSection, @$needSection, @$stepsSection]
        else if not @model.craftsman.complete
            toShow.push el for el in [@$workingSection]
            toHide.push el for el in [@$instructionsSection, @$toolsSection, @$needSection, @$stepsSection]
        else
            toShow.push el for el in [@$toolsSection, @$needSection, @$stepsSection]
            toHide.push el for el in [@$instructionsSection, @$workingSection]

        @show $el for $el in toShow
        @hide $el for $el in toHide

    _refreshSteps: ->
        steps = @model.craftsman.plan?.steps or []
        @_stepControllers ?= []
        index = 0

        for step in steps
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
