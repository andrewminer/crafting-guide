#
# Crafting Guide - github_user.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{BaseModel} = require("crafting-guide-common").deprecated

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
