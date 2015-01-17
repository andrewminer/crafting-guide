###
Crafting Guide - mod.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Url}     = require '../constants'

########################################################################################################################

module.exports = class Mod extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.name? then throw new Error 'attributes.name is required'
        attributes.id = attributes.slug = _.slugify attributes.name
        super attributes, options

    # Backbone.View Overrides ######################################################################

    parse: (response)->

    url: ->
        return Url.mod modSlug:@slug
