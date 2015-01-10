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
        minecraft = new ModVersion name:'Minecraft', version:'1.7.10'
        minecraft.addItem new Item name:'Wool'
        minecraft.addItem new Item name:'Bed', recipes:['']
        minecraft.registerSlug 'iron_chestplate', 'Iron Chestplate'

        buildcraft = new ModVersion name:'Buildcraft', version:'4.0'
        buildcraft.addItem new Item name:'Stone Gear', recipes:['']
        buildcraft.addItem new Item name:'Bed', recipes:['']

        industrialCraft = new ModVersion name:'Industrial Craft', version:'2.0'
        industrialCraft.addItem new Item name:'Resin'
        industrialCraft.addItem new Item name:'Rubber', recipes:['']

        modPack = new ModPack modVersions:[minecraft, buildcraft, industrialCraft]

    describe 'enableModsForItem', ->

        it 'it ignores already-enabled mod versions', ->
            buildcraft.enabled = true
            modPack.enableModsForItem 'Stone Gear'

            minecraft.enabled.should.be.true
            buildcraft.enabled.should.be.true
            industrialCraft.enabled.should.be.false

        it 'it ignores mod versions not containing the item', ->
            modPack.enableModsForItem 'Stone Gear'

            minecraft.enabled.should.be.true
            buildcraft.enabled.should.be.true
            industrialCraft.enabled.should.be.false

        it 'enables disabled mod versions with the item', ->
            modPack.enableModsForItem 'Rubber'

            minecraft.enabled.should.be.true
            buildcraft.enabled.should.be.false
            industrialCraft.enabled.should.be.true

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
            display.iconUrl.should.equal '/data/minecraft/images/bed.png'
            display.itemUrl.should.equal '/item/Bed'
            display.itemName.should.equal 'Bed'
            display.modSlug.should.equal 'minecraft'

        it 'returns all data for an item in an enabled mod', ->
            buildcraft.enabled = true
            display = modPack.findItemDisplay 'stone_gear'
            display.iconUrl.should.equal '/data/buildcraft/images/stone_gear.png'
            display.itemUrl.should.equal '/item/Stone%20Gear'
            display.itemName.should.equal 'Stone Gear'
            display.modSlug.should.equal 'buildcraft'

        it 'returns data even for a disabled mod', ->
            display = modPack.findItemDisplay 'stone_gear'
            display.itemName.should.equal 'Stone Gear'

        it 'assumes an unfound item is from Minecraft', ->
            display = modPack.findItemDisplay 'iron_chestplate'
            display.iconUrl.should.equal '/data/minecraft/images/iron_chestplate.png'
            display.itemUrl.should.equal '/item/Iron%20Chestplate'
            display.itemName.should.equal 'Iron Chestplate'
            display.modSlug.should.equal 'minecraft'

    describe 'gatherNames', ->

        it 'finds all registered item names', ->
            buildcraft.enabled = true
            industrialCraft.enabled = true
            (i.value for i in modPack.gatherNames()).sort().should.eql ['Bed', 'Rubber', 'Stone Gear']

        it 'ignores duplicate item names', ->
            buildcraft.enabled = true
            names = modPack.gatherNames()
            bedName = (e for e in names when e.value is 'Bed')[0]
            bedName.should.eql value:'Bed', label:'Bed (from Minecraft 1.7.10)'

        it 'alphabetizes the item names', ->
            buildcraft.enabled = true
            industrialCraft.enabled = true
            (i.value for i in modPack.gatherNames()).should.eql ['Bed', 'Rubber', 'Stone Gear']

        it 'ignores non-craftable items', ->
            (n.value for n in modPack.gatherNames()).sort().should.eql ['Bed']

        it 'ignores disabled mod versions', ->
            (n.value for n in modPack.gatherNames()).should.not.include 'Stone Gear'

        it "doesn't ignore disabled mod versions when include disabled is requested", ->
            (n.value for n in modPack.gatherNames(includeDisabled:true)).should.include 'Stone Gear'

    describe 'hasRecipe', ->

        it 'returns true when the item is present and has recipes', ->
            modPack.hasRecipe('Bed').should.be.true

        it 'returns false when the item is not present', ->
            modPack.hasRecipe('Iron Sword').should.be.false

        it 'returns false when the item does not have recipes', ->
            modPack.hasRecipe('Wool').should.be.false

        it 'ignores disabled mod versions', ->
            modPack.hasRecipe('Stone Gear').should.be.false

        it 'includes disabled mod versions when include disabled is requested', ->
            modPack.hasRecipe('Stone Gear', includeDisabled:true).should.be.true
