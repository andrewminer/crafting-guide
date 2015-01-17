###
Crafting Guide - mod.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Mod extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.name? then throw new Error 'attributes.name is required'
        attributes.id = attributes.slug = _.slugify attributes.name
        super attributes, options

    # Backbone.View Overrides ######################################################################

    parse: (response)->

    sync: (method, model, options={})->
        if method isnt 'read' then throw new Error "Mod data can only be read, not #{method}d"
        super method, model, options

    url: ->
        return "/data/#{@slug}/mod.cg"
