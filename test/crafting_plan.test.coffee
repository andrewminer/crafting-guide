###
Crafting Guide - crafting_plan.test.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

CraftingPlan = require '../src/coffee/models/crafting_plan'
ItemSlug     = require '../src/coffee/models/item_slug'
Mod          = require '../src/coffee/models/mod'
ModPack      = require '../src/coffee/models/mod_pack'
ModVersion   = require '../src/coffee/models/mod_version'

########################################################################################################################

modPack = plan = null

########################################################################################################################

describe 'crafting_plan.coffee', ->

    beforeEach ->
        mod = new Mod name:'Minecraft', slug:'minecraft'
        mod.addModVersion new ModVersion modSlug:mod.slug, version:'1.7.10'
        mod.activeModVersion.parse """
            schema:1

            item:Oak Plank;      recipe:; input:Oak Log;                pattern:... .0. ...; quantity:4
            item:Stick;          recipe:; input:Oak Plank;              pattern:... .0. .0.; quantity:4
            item:Crafting Table; recipe:; input:Oak Plank;              pattern:00. 00. ...
            item:Furnace;        recipe:; input:Cobblestone;            pattern:000 0.0 000; tools:Crafting Table
            item:Iron Ingot;     recipe:; input:Iron Ore, furnace fuel; pattern:.0. ... .1.; tools:Furnace
            item:Iron Sword;     recipe:; input:Iron Ingot, Stick;      pattern:.0. .0. .1.; tools:Crafting Table
        """
        modPack = new ModPack
        modPack.addMod mod

        plan = new CraftingPlan modPack:modPack, includingTools:false

    describe 'craft', ->

        describe 'under the simplest conditions', ->

            it 'can craft a single step recipe', ->
                plan.want.add ItemSlug.slugify 'oak_plank'
                plan.craft()
                plan.need.unparse().should.equal 'oak_log'
                plan.result.unparse().should.equal '4.oak_plank'

            it 'can craft a multi-step recipe', ->
                plan.want.add ItemSlug.slugify 'crafting_table'
                plan.craft()
                plan.need.unparse().should.equal 'oak_log'
                plan.result.unparse().should.equal 'crafting_table'

            it 'can craft a multi-step recipe using tools', ->
                plan.want.add ItemSlug.slugify 'furnace'
                plan.craft()
                plan.need.unparse().should.equal '8.cobblestone'
                plan.result.unparse().should.equal 'furnace'

            it 'can craft a multi-step recipe re-using tools', ->
                plan.want.add ItemSlug.slugify 'iron_sword'
                plan.craft()
                plan.need.unparse().should.equal '2.furnace_fuel:2.iron_ore:oak_log'
                plan.result.unparse().should.equal 'iron_sword:2.oak_plank:3.stick'

        describe 'with building tools', ->

            it 'can craft a multi-step recipe using tools', ->
                plan.includingTools = true
                plan.want.add ItemSlug.slugify 'furnace'
                plan.craft()
                plan.need.unparse().should.equal '8.cobblestone:oak_log'
                plan.result.unparse().should.equal 'crafting_table:furnace'

            it 'can craft a multi-step recipe re-using tools', ->
                plan.includingTools = true
                plan.want.add ItemSlug.slugify 'iron_sword'
                plan.craft()

                plan.need.unparse().should.eql '8.cobblestone:2.furnace_fuel:2.iron_ore:2.oak_log'
                plan.result.unparse().should.equal 'crafting_table:furnace:' +
                    'iron_sword:2.oak_plank:3.stick'
