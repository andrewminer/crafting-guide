###
Crafting Guide - base_model.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class BaseModel extends Backbone.Model

    constructor: (attributes={}, options={})->
        super attributes, options

        makeGetter = (name)-> return -> @get name
        makeSetter = (name)-> return (value)-> @set name, value
        for name in _.keys attributes
            continue if name is 'id'
            Object.defineProperty this, name, get:makeGetter(name), set:makeSetter(name)

    # Backbone.Model Overrides #####################################################################

    sync: -> # do nothing

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name} (#{@cid})"
