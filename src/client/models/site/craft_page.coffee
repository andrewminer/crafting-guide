#
# Crafting Guide - craft_page.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Inventory} = require("crafting-guide-common").models
{Observable} = require("crafting-guide-common").util
{PlanBuilder} = require("crafting-guide-common").crafting
{ResourcesEvaluator} = require("crafting-guide-common").crafting
{StepsEvaluator} = require("crafting-guide-common").crafting

########################################################################################################################

module.exports = class CraftPage extends Observable

    constructor: (attributes={})->
        super

        @muted -> @modPack = attributes.modPack

        @_currentPlan = null
        @_have        = new Inventory
        @_planBuilder = new PlanBuilder new StepsEvaluator
        @_want        = new Inventory

        @_consumeParams attributes.params

        @_have.on Observable::ANY, this, "_onHaveChanged"
        @_want.on Observable::ANY, this, "_onWantChanged"

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        currentPlan:
            get: -> return @_currentPlan
            set: -> throw new Error "currentPlan cannot be assigned"

        have:
            get: -> return @_have
            set: -> throw new "have cannot be assigned"

        isDirty:
            get: -> return @_isDirty
            set: -> throw new Error "isDirty cannot be assigned"

        isOutdated:
            get: -> return @currentPlan? and @isDirty
            set: -> throw new Error "isOutdated cannot be assigned"

        modPack:
            get: -> return @_modPack
            set: (modPack)->
                if @_modPack? then throw new Error "modPack cannot be reassigned"
                if not modPack? then throw new Error "modPack is required"
                @_modPack = modPack

        planBuilder:
            get: -> return @_planBuilder
            set: -> throw new Error "planBuilder cannot be assigned"

        want:
            get: -> return @_want
            set: -> throw new Error "want cannot be assigned"

    # Public Methods ###############################################################################

    createPlan: ->
        newPlan = @_planBuilder.createPlan @_want, @_have
        @triggerPropertyChange "currentPlan", @_currentPlan, newPlan, ->
            @_currentPlan = newPlan
            @triggerPropertyChange "isDirty", @_isDirty, false

    # Private Methods ##############################################################################

    _consumeParams: (params)->
        return unless params?.inventoryText?

        newWant = Inventory.fromUrlString params.inventoryText, @modPack
        @_want.clear()

        for itemId, stack of newWant.stacks
            continue unless stack.item.isCraftable
            @_want.add stack.item, stack.quantity

    _onHaveChanged: ->
        @triggerPropertyChange "isDirty", @_isDirty, true

    _onWantChanged: ->
        @triggerPropertyChange "isDirty", @_isDirty, true, ->
            @_isDirty = true
            if @want.isEmpty then @triggerPropertyChange "currentPlan", @_currentPlan, null
