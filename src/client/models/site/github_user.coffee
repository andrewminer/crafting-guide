#
# Crafting Guide - github_user.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'

########################################################################################################################

module.exports = class GitHubUser extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.avatarUrl ?= attributes.avatar_url ?= null
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
