#
# Crafting Guide - tutorial.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'

########################################################################################################################

module.exports = class Tutorial extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.name?.length > 0 then throw new Error "attributes.name cannot be empty"
        attributes.modSlug     ?= null
        attributes.officialUrl ?= null
        attributes.sections    ?= []
        attributes.slug        ?= _.slugify attributes.name
        attributes.videos      ?= []
        super attributes, options

    # Backbone.Model Overrides #####################################################################

    parse: (text)->
        TutorialParser = require '../parsing/tutorial_parser' # to avoid require cycles
        @_parser ?= new TutorialParser model:this
        @_parser.parse text

        return null # prevent calling `set`

    url: ->
        return c.url.tutorialData modSlug:@modSlug, tutorialSlug:@slug
