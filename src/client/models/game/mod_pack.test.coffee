#
# Crafting Guide - mod_pack.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Item       = require './item'
ItemSlug   = require './item_slug'
Mod        = require './mod'
ModPack    = require './mod_pack'
ModVersion = require './mod_version'

########################################################################################################################

buildcraft = industrialCraft = minecraft = modPack = null

########################################################################################################################

describe 'mod_pack.coffee', ->

    beforeEach ->
        minecraft = new Mod slug:'minecraft', name:'Minecraft'
        minecraft.addModVersion new ModVersion modSlug:minecraft.slug, version:'1.7.10'
        minecraft.activeModVersion.addItem new Item name:'Wool'
        minecraft.activeModVersion.addItem new Item name:'Bed', recipes:['']
        minecraft.activeModVersion.registerName ItemSlug.slugify('iron_chestplate'), 'Iron Chestplate'

        buildcraft = new Mod slug:'buildcraft', name:'Buildcraft'
        buildcraft.addModVersion new ModVersion modSlug:buildcraft.slug, version:'6.2.6'
        buildcraft.activeModVersion.addItem new Item name:'Stone Gear', recipes:['']
        buildcraft.activeModVersion.addItem new Item name:'Wrench', recipes:['']
        buildcraft.activeVersion = Mod.Version.None

        industrialCraft = new Mod slug:'industrial_craft', name:'Industrial Craft'
        industrialCraft.addModVersion new ModVersion modSlug:industrialCraft.slug, version:'2.0'
        industrialCraft.activeModVersion.addItem new Item name:'Resin'
        industrialCraft.activeModVersion.addItem new Item name:'Rubber'
        industrialCraft.activeModVersion.addItem new Item name:'Wrench', recipes:['']
        industrialCraft.activeVersion = Mod.Version.None

        modPack = new ModPack
        modPack.addMod minecraft
        modPack.addMod buildcraft
        modPack.addMod industrialCraft

    describe 'findItem', ->

        it 'can find an item by partial slug', ->
            item = modPack.findItem ItemSlug.slugify 'wool'
            item.slug.qualified.should.equal 'minecraft__wool'

        it 'can find an item by full slug', ->
            item = modPack.findItem ItemSlug.slugify 'minecraft__wool'
            item.name.should.equal 'Wool'

        it 'can find an ambiguous item by full slug', ->
            buildcraft.activeVersion = Mod.Version.Latest
            industrialCraft.activeVersion = Mod.Version.Latest
            item = modPack.findItem ItemSlug.slugify 'industrial_craft__wrench'
            item.name.should.equal 'Wrench'
            item.modVersion.mod.name.should.equal 'Industrial Craft'

        it 'can find an ambiguous item by partial slug', ->
            buildcraft.activeVersion = Mod.Version.Latest
            industrialCraft.activeVersion = Mod.Version.Latest
            item = modPack.findItem ItemSlug.slugify 'wrench'
            item.name.should.equal 'Wrench'
            item.modVersion.mod.name.should.equal 'Buildcraft'

    describe 'findItemByName', ->

        it 'finds the requested item', ->
            item = modPack.findItemByName 'Bed'
            item.name.should.equal 'Bed'

        it 'ignores disabled mod versions', ->
            item = modPack.findItemByName 'Stone Gear'
            expect(item).to.be.null

    describe 'findItemDisplay', ->

        it 'returns all data for a regular Minecraft item', ->
            display = modPack.findItemDisplay ItemSlug.slugify 'bed'
            display.iconUrl.should.equal '/data/minecraft/items/bed/icon.png'
            display.itemUrl.should.equal '/browse/minecraft/bed/'
            display.itemName.should.equal 'Bed'
            display.modSlug.should.equal 'minecraft'

        it 'returns all data for an item in an enabled mod', ->
            buildcraft.activeVersion = '6.2.6'
            display = modPack.findItemDisplay ItemSlug.slugify 'stone_gear'
            display.iconUrl.should.equal '/data/buildcraft/items/stone_gear/icon.png'
            display.itemUrl.should.equal '/browse/buildcraft/stone_gear/'
            display.itemName.should.equal 'Stone Gear'
            display.modSlug.should.equal 'buildcraft'

        it 'assumes an unfound item is from Minecraft', ->
            display = modPack.findItemDisplay ItemSlug.slugify 'iron_chestplate'
            display.iconUrl.should.equal '/data/minecraft/items/iron_chestplate/icon.png'
            display.itemUrl.should.equal '/browse/minecraft/iron_chestplate/'
            display.itemName.should.equal 'Iron Chestplate'
            display.modSlug.should.equal 'minecraft'
