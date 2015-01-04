###
Crafting Guide - mod_version.test.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

Item       = require '../src/scripts/models/item'
ModVersion = require '../src/scripts/models/mod_version'

########################################################################################################################

modVersion = null

########################################################################################################################

describe 'ModVersion', ->

    beforeEach -> modVersion = new ModVersion name:'Test', version:'0.0'

    describe 'constructor', ->

        it 'requires a mod name', ->
            expect(-> new ModVersion version:'0.0').to.throw Error, 'name cannot be empty'

        it 'requires a mod version', ->
            expect(-> new ModVersion name:'Test').to.throw Error, 'version cannot be empty'

        it 'supplies default values', ->
            modVersion.description.should.equal ''
            modVersion.items.should.eql {}
            modVersion.enabled.should.be.false

    describe 'addItem', ->

        it 'refuses to add duplicates', ->
            modVersion.addItem new Item name:'Wool'
            expect(-> modVersion.addItem new Item name:'Wool').to.throw Error, 'duplicate item for wool'

        it 'adds an item indexes by its slug', ->
            modVersion.addItem new Item name:'Wool'
            modVersion.items.wool.name.should.equal 'Wool'

    describe 'compareTo', ->

        it 'lists required mods first', ->
            minecraft = new ModVersion name:'Minecraft', version:'1.7.10'
            modVersion.compareTo(minecraft).should.equal +1
            minecraft.compareTo(modVersion).should.equal -1

        it 'sorts by name second', ->
            buildcraft = new ModVersion name:'Buildcraft', version:'3.0'
            modVersion.compareTo(buildcraft).should.equal +1
            buildcraft.compareTo(modVersion).should.equal -1

    describe 'findItemByName', ->

        it 'locates items by slugified name', ->
            modVersion.addItem new Item name:'Crafting Table'
            modVersion.findItemByName('Crafting Table').slug.should.equal 'crafting_table'

    describe 'gatherRecipeNames', ->

        it 'skips names already found', ->
            modVersion.addItem new Item name:'Wool'
            modVersion.addItem new Item name:'Oak Wood Planks', recipes:['foo']
            names = modVersion.gatherRecipeNames {wool:true}
            names.wool.should.be.true
            names.oak_wood_planks.value.should.equal 'Oak Wood Planks'

        it 'only includes craftable items', ->
            modVersion.addItem new Item name:'Wool'
            modVersion.addItem new Item name:'Oak Wood Planks', recipes:['foo']
            names = modVersion.gatherRecipeNames()
            _.keys(names).should.eql ['oak_wood_planks']

        it 'computes the proper value and label', ->
            modVersion.addItem new Item name:'Oak Wood Planks', recipes:['foo']
            names = modVersion.gatherRecipeNames()
            names.oak_wood_planks.value.should.equal 'Oak Wood Planks'
            names.oak_wood_planks.label.should.equal 'Oak Wood Planks (from Test 0.0)'

    describe 'hasRecipe', ->

        it 'returns false for an unknown item', ->
            modVersion.addItem new Item name:'Oak Wood Planks', recipes:['foo']
            modVersion.hasRecipe('Pineapple Upside-Down Cake').should.be.false

        it 'returns false for a un-craftable item', ->
            modVersion.addItem new Item name:'Wool'
            modVersion.hasRecipe('Wool').should.be.false

        it 'returns true for a craftable item', ->
            modVersion.addItem new Item name:'Oak Wood Planks', recipes:['foo']
            modVersion.hasRecipe('Oak Wood Planks').should.be.true
