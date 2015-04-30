###
Crafting Guide - tutorial.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel      = require './base_model'
TutorialParser = require './tutorial_parser'
_              = require 'underscore'
{Url}          = require '../constants'

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
        TutorialParser = require './tutorial_parser' # to avoid require cycles
        @_parser ?= new TutorialParser model:this
        @_parser.parse text

        return null # prevent calling `set`

    url: ->
        return Url.tutorialData modSlug:@modSlug, tutorialSlug:@slug
