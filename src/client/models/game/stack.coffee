#
# Crafting Guide - stack.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'

########################################################################################################################

module.exports = class Stack extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.itemSlug? then throw new Error 'attributes.itemSlug is required'
        attributes.quantity ?= 1
        options.logEvents   ?= false
        super attributes, options

    # Object Overrides #############################################################################

    toString: ->
        return "#{@quantity} #{@itemSlug}"
