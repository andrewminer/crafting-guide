###
# Crafting Guide - crafting_plan.test.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

ModPack = require '../src/scripts/models/mod_pack'
CraftingPlan  = require '../src/scripts/models/crafting_plan'

########################################################################################################################

catalog = plan = null

########################################################################################################################

describe 'CraftingPlan', ->

    beforeEach ->
        catalog = new ModPack
        catalog.loadBookData {
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

        plan = new CraftingPlan catalog

    describe 'craft', ->

        describe 'under the simplest conditions', ->

            it 'can craft a single step recipe', ->
                plan.craft 'Oak Plank'
                plan.need.toList().should.eql ['Oak Log']
                plan.result.toList().should.eql [[4, 'Oak Plank']]

            it 'can craft a multi-step recipe', ->
                plan.craft 'Crafting Table'
                plan.need.toList().should.eql ['Oak Log']
                plan.result.toList().should.eql ['Crafting Table']

            it 'can craft a multi-step recipe using tools', ->
                plan.craft 'Furnace'
                plan.need.toList().should.eql [[8, 'Cobblestone']]
                plan.result.toList().should.eql ['Furnace']

            it 'can craft a multi-step recipe re-using tools', ->
                plan.craft 'Iron Sword'
                plan.need.toList().should.eql [[2, 'Iron Ore'], 'Oak Log', [2, '{furnace fuel}']]
                plan.result.toList().should.eql ['Iron Sword', [2, 'Oak Plank'], [3, 'Stick']]

        describe 'with building tools', ->

            it 'can craft a multi-step recipe using tools', ->
                plan.includingTools = true
                plan.craft 'Furnace'
                plan.need.toList().should.eql [[8, 'Cobblestone'], 'Oak Log']
                plan.result.toList().should.eql ['Crafting Table', 'Furnace']

            it 'can craft a multi-step recipe re-using tools', ->
                plan.includingTools = true
                plan.craft 'Iron Sword'
                plan.need.toList().should.eql [
                    [8, 'Cobblestone'], [2, 'Iron Ore'], [2, 'Oak Log'], [2, '{furnace fuel}'],
                ]
                plan.result.toList().should.eql [
                    'Crafting Table', 'Furnace', 'Iron Sword', [2, 'Oak Plank'], [3, 'Stick']
                ]

        describe 'using existing inventory', ->
