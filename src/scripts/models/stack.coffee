###
Crafting Guide - stack.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Stack extends BaseModel

    constructor: (attributes={})->
        if not attributes.slug? then throw new Error 'attributes.slug is required'
        attributes.quantity ?= 1
        super attributes

    # Object Overrides #############################################################################

    toString: ->
        return "#{@quantity} #{@slug}"
