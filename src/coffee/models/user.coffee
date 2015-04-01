###
Crafting Guide - user.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'
{Url}     = require '../constants'

########################################################################################################################

module.exports = class GitHubUser extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.avatarUrl ?= null
        attributes.email     ?= null
        attributes.login     ?= null
        attributes.name      ?= null
        super attributes, options

    # Property Methods #############################################################################

    isAuthenticated: ->
        return @login?

    Object.defineProperties @prototype,
        authenticated: {get:@prototype.isAuthenticated}

    # Object Overrides #############################################################################

    toString: ->
        return "#{@name} (#{@login})"
