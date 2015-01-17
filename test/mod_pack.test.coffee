###
Crafting Guide - mod_pack.test.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

Item       = require '../src/scripts/models/item'
ModPack    = require '../src/scripts/models/mod_pack'
ModVersion = require '../src/scripts/models/mod_version'

########################################################################################################################

buildcraft = industrialCraft = minecraft = modPack = null

########################################################################################################################

describe 'ModPack', ->

    beforeEach ->
        minecraft = new ModVersion name:'Minecraft', version:'1.7.10', enabled:true
        minecraft.addItem new Item name:'Wool'
        minecraft.addItem new Item name:'Bed', recipes:['']
        minecraft.registerSlug 'iron_chestplate', 'Iron Chestplate'

        buildcraft = new ModVersion name:'Buildcraft', version:'6.2.6', enabled:false
        buildcraft.addItem new Item name:'Stone Gear', recipes:['']
        buildcraft.addItem new Item name:'Bed', recipes:['']

        industrialCraft = new ModVersion name:'Industrial Craft', version:'2.0', enabled:false
        industrialCraft.addItem new Item name:'Resin'
        industrialCraft.addItem new Item name:'Rubber'

        modPack = new ModPack
        modPack.addModVersion minecraft
        modPack.addModVersion buildcraft
        modPack.addModVersion industrialCraft

    describe 'findItemByName', ->

        it 'finds the requested item', ->
            item = modPack.findItemByName 'Bed'
            item.name.should.equal 'Bed'

        it 'ignores disabled mod versions', ->
            item = modPack.findItemByName 'Stone Gear'
            expect(item).to.be.null

        it "doesn't ignore mod versions when include disabled is requested", ->
            item = modPack.findItemByName 'Stone Gear', includeDisabled:true
            item.name.should.equal 'Stone Gear'

    describe 'findItemDisplay', ->

        it 'returns all data for a regular Minecraft item', ->
            display = modPack.findItemDisplay 'bed'
            display.iconUrl.should.equal '/data/minecraft/1.7.10/images/bed.png'
            display.itemUrl.should.equal '/item/Bed'
            display.itemName.should.equal 'Bed'
            display.modSlug.should.equal 'minecraft'

        it 'returns all data for an item in an enabled mod', ->
            buildcraft.enabled = true
            display = modPack.findItemDisplay 'stone_gear'
            display.iconUrl.should.equal '/data/buildcraft/6.2.6/images/stone_gear.png'
            display.itemUrl.should.equal '/item/Stone%20Gear'
            display.itemName.should.equal 'Stone Gear'
            display.modSlug.should.equal 'buildcraft'

        it 'returns data even for a disabled mod', ->
            display = modPack.findItemDisplay 'stone_gear'
            display.itemName.should.equal 'Stone Gear'

        it 'assumes an unfound item is from Minecraft', ->
            display = modPack.findItemDisplay 'iron_chestplate'
            display.iconUrl.should.equal '/data/minecraft/1.7.10/images/iron_chestplate.png'
            display.itemUrl.should.equal '/item/Iron%20Chestplate'
            display.itemName.should.equal 'Iron Chestplate'
            display.modSlug.should.equal 'minecraft'
