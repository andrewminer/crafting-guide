###
Crafting Guide - mod_page_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController   = require './base_controller'
{Duration}       = require '../constants'
ModPack          = require '../models/mod_pack'
RecipeController = require './recipe_controller'

########################################################################################################################

module.exports = class ModPageController extends BaseController

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'mod_page'
        super options

        @_modPack           = options.modPack
        @_recipeControllers = []

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$title = @$('h1')
        @$recipes = @$('.recipes')
        super

    refresh: ->
        @$title.html if @model? then @model.name else ''

        controllerIndex = 0
        if @model?.activeModVersion?.isLoaded
            @$recipes.show duration:Duration.fast
            @model.eachItem (item)=>
                controller = @_recipeControllers[controllerIndex]
                if not controller?
                    controller = new RecipeController modPack:@_modPack
                    controller.render()
                    @_recipeControllers.push controller
                    @$recipes.append controller.$el

                controller.model = item.getPrimaryRecipe()
                controllerIndex += 1
        else
            @$recipes.hide duration:Duration.fast

        while @_recipeControllers.length > controllerIndex
            controller = @_recipeControllers.pop()
            controller.$el.slideUp duration:Duration.fast, complete:-> @remove()

        super
