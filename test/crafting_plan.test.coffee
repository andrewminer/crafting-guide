###
Crafting Guide - crafting_plan.test.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

ModPack      = require '../src/scripts/models/mod_pack'
CraftingPlan = require '../src/scripts/models/crafting_plan'

########################################################################################################################

modPack = plan = null

########################################################################################################################

describe 'CraftingPlan', ->

    beforeEach ->
        modPack = new ModPack
        modPack.loadModVersionData {
            version: 1
            mod_name: 'Minecraft'
            mod_version: '1.7.10'
            recipes: [
                { input:'Oak Log',                                              output:[[4, 'Oak Plank']] }
                { input:[[2, 'Oak Plank']],                                     output:[[4, 'Stick']] }
                { input:[[4, 'Oak Plank']],                                     output:'Crafting Table' }
                { input:[[8, 'Cobblestone']],           tools:'Crafting Table', output:'Furnace' }
                { input:['Iron Ore', '{furnace fuel}'], tools:'Furnace',        output:'Iron Ingot' }
                { input:[[2, 'Iron Ingot'], 'Stick'],   tools:'Crafting Table', output:'Iron Sword' }
            ]
        }
        logger.debug "modPack: #{modPack}"
        logger.debug "modVersion: #{modPack.modVersions[0]}"

        plan = new CraftingPlan modPack

    describe 'craft', ->

        describe 'under the simplest conditions', ->

            it 'can craft a single step recipe', ->
                plan.craft 'Oak Plank'
                plan.need.toList().should.eql ['oak_log']
                plan.result.toList().should.eql [[4, 'oak_plank']]

            it 'can craft a multi-step recipe', ->
                plan.craft 'Crafting Table'
                plan.need.toList().should.eql ['oak_log']
                plan.result.toList().should.eql ['crafting_table']

            it 'can craft a multi-step recipe using tools', ->
                plan.craft 'Furnace'
                plan.need.toList().should.eql [[8, 'cobblestone']]
                plan.result.toList().should.eql ['furnace']

            it 'can craft a multi-step recipe re-using tools', ->
                plan.craft 'Iron Sword'
                plan.need.toList().should.eql [[2, 'furnace_fuel'], [2, 'iron_ore'], 'oak_log']
                plan.result.toList().should.eql ['iron_sword', [2, 'oak_plank'], [3, 'stick']]

        describe 'with building tools', ->

            it 'can craft a multi-step recipe using tools', ->
                plan.includingTools = true
                plan.craft 'Furnace'
                plan.need.toList().should.eql [[8, 'cobblestone'], 'oak_log']
                plan.result.toList().should.eql ['crafting_table', 'furnace']

            it 'can craft a multi-step recipe re-using tools', ->
                plan.includingTools = true
                plan.craft 'Iron Sword'
                plan.need.toList().should.eql [
                    [8, 'cobblestone'], [2, 'furnace_fuel'], [2, 'iron_ore'], [2, 'oak_log']
                ]
                plan.result.toList().should.eql [
                    'crafting_table', 'furnace', 'iron_sword', [2, 'oak_plank'], [3, 'stick']
                ]

        describe 'using existing inventory', ->
