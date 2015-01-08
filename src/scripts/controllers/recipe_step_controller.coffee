###
Crafting Guide - recipe_step_controller.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseController = require './base_controller'

########################################################################################################################

module.exports = class RecipeStepController extends BaseController

    constructor: (options={})->
        if not options.model? then throw new Error 'options.model is required'
        if not options.modPack? then throw new Error 'options.modPack is required'
        options.templateName = 'recipe_step'
        super options

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$slotImages = (@$slots.push $(el) for el in @$('.table-slot img'))
        @$output     = @$('.output')
        super

    refresh: ->