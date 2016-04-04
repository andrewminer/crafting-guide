#
# Crafting Guide - fixtures.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

GraphBuilder = require './graph_builder'
Inventory    = require '../game/inventory'
ItemSlug     = require '../game/item_slug'
Mod          = require '../game/mod'
ModPack      = require '../game/mod_pack'
ModVersion   = require '../game/mod_version'
PlanBuilder  = require './plan_builder'

########################################################################################################################

MOD_VERSION_FILE =
    """
    schema: 1

    item: Bed
        recipe:
            input: Oak Planks, Wool
            pattern: ... 000 111

    item: Charcoal
        recipe:
            input: 8 Oak Wood, Coal
            pattern: .0. ... .1.
            quantity: 8

    item: Crafting Table
        recipe:
            input: Oak Planks
            pattern: .00 .00 ...

    item: Coal
        gatherable: yes

    item: Cobblestone
        gatherable: yes

    item: Copper Block
        recipe:
            input: Copper Ingot
            pattern: 000 000 000
            tools: Crafting Table

    item: Copper Ingot
        recipe:
            input: 8 Copper Ore, Coal
            pattern: .0. ... .1.
            quantity: 8
            tools: Furnace
        recipe:
            input: 8 Copper Ore, Charcoal
            pattern: .0. ... .1.
            quantity: 8
            tools: Furnace
        recipe:
            input: Copper Block
            pattern: ... .0. ...
            quantity: 9

    item: Copper Ore
        gatherable: yes

    item: Furnace
        recipe:
            input: Cobblestone
            pattern: 000 0.0 000
            tools: Crafting Table

    item: Iron Ore
        gatherable: yes

    item: Iron Ingot
        recipe:
            input: 8 Iron Ore, Charcoal
            pattern: .0. ... .1.
            quantity: 8
            tools: Furnace
        recipe:
            input: 8 Iron Ore, Coal
            pattern: .0. ... .1.
            quantity: 8
            tools: Furnace

    item: Iron Sword
        recipe:
            input: Iron Ingot, Stick
            pattern: .0. .0. .1.
            tools: Crafting Table

    item: Lever
        recipe:
            input: Stick, Cobblestone
            pattern: .0. .1. ...

    item: Oak Planks
        recipe:
            input: Oak Wood
            pattern: ... .0. ...
            quantity: 4

    item: Oak Wood
        gatherable: yes

    item: Stick
        recipe:
            input: Oak Planks
            pattern: .0. .0. ...
            quantity: 4

    item: String
        gatherable: yes

    item: Wool
        gatherable: yes
        recipe:
            input: String
            pattern: 00. 00. ...
    """

########################################################################################################################

module.exports = fixtures =

    makeGraphBuilder: ->
        return new GraphBuilder modPack:fixtures.makeModPack(), want:new Inventory

    makeModPack: ->
        modPack = new ModPack

        mod = new Mod name:'Test', slug:'test'
        modPack.addMod mod

        modVersion = new ModVersion modSlug:'test', version:'0.0'
        modVersion.parse MOD_VERSION_FILE
        mod.addModVersion modVersion

        return modPack

    makePlans: (stacks...)->
        modPack = fixtures.makeModPack()

        have = new Inventory
        want = new Inventory
        for stack in stacks
            want.add ItemSlug.slugify(stack[1]), stack[0]

        graphBuilder = new GraphBuilder modPack:modPack, want:want
        graphBuilder.expandGraph()

        planBuilder = new PlanBuilder graphBuilder.rootNode, modPack, want:want, have:have
        return planBuilder.producePlans()

    makeTree: (itemSlug, quantity=1)->
        want = new Inventory
        want.add ItemSlug.slugify itemSlug

        builder = new GraphBuilder modPack:fixtures.makeModPack(), want:want
        builder.expandGraph()

        return builder.rootNode
