###
# Crafting Guide - item.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

BaseModel = require './base_model'

########################################################################################################################

module.exports = class Item extends BaseModel

    constructor: (attributes={}, options={})->
        attributes.name     ?= ''
        attributes.quantity ?= 1
        super attributes, options

    # Public Methods ###############################################################################