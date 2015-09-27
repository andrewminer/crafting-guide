###
Crafting Guide - sample_modpack.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

GraphBuilder = require '../../src/coffee/models/crafting/graph_builder'
ItemSlug     = require '../../src/coffee/models/item_slug'
Mod          = require '../../src/coffee/models/mod'
ModPack      = require '../../src/coffee/models/mod_pack'
ModVersion   = require '../../src/coffee/models/mod_version'
PlanBuilder  = require '../../src/coffee/models/crafting/plan_builder'

########################################################################################################################

MOD_VERSION_FILE =
    """
    schema: 1

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

    item: Cobblestone

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

    item: Furnace
        recipe:
            input: Cobblestone
            pattern: 000 0.0 000
            tools: Crafting Table

    item: Iron Ore

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

    item: Stick
        recipe:
            input: Oak Planks
            pattern: .0. .0. ...
            quantity: 4
    """

########################################################################################################################

module.exports = fixtures =

    makeGraphBuilder: ->
        return new GraphBuilder modPack:fixtures.makeModPack()

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

        graphBuilder = fixtures.makeGraphBuilder()
        for stack in stacks
            graphBuilder.wanted.add ItemSlug.slugify(stack[1]), stack[0]
        graphBuilder.expandGraph()

        planBuilder = new PlanBuilder graphBuilder.rootNode, wanted:graphBuilder.wanted
        return planBuilder.producePlans()

    makeTree: (itemSlug, quantity=1)->
        builder = fixtures.makeGraphBuilder()
        builder.wanted.add ItemSlug.slugify itemSlug
        builder.expandGraph()

        return builder.rootNode
