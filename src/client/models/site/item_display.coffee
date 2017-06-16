#
# Crafting Guide - item_page.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_           = require "../../../common/underscore"
c           = require "../../../common/constants"
{Inventory} = require("crafting-guide-common").models

########################################################################################################################

module.exports = class ItemDisplay

    constructor: (item)->
        @item = item

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        craftingUrl:
            get: ->
                inventory = new Inventory
                inventory.add @item
                c.url.crafting inventoryText:inventory.unparse()

        iconUrl:
            get: -> return c.url.itemIcon modId:@_item.mod.id, itemSlug:@slug
            set: -> throw new Error "iconUrl cannot be assigned"

        item:
            get: -> return @_item
            set: (item)->
                if @_item? then throw new Error "item cannot be re-assigned"
                if not item? then throw new Error "item is required"
                @_item = item

        modUrl:
            get: -> return c.url.mod modId:@item.mod.id
            set: -> throw new Error "modUrl cannot be assigned"

        name:
            get: -> return @item.displayName
            set: -> throw new Error "name cannot be assigned"

        slug:
            get: -> return _.slugify @name
            set: -> throw new Error "slug cannot be assigned"

        url:
            get: -> return c.url.item modId:@_item.mod.id, itemSlug:@slug
            set: -> throw new Error "url cannot be assigned"
