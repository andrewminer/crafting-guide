###
Crafting Guide - mod_version.test.coffee

Copyright (c) 2014-2015 by Redwood Labs
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
            expect(-> new ModVersion version:'0.0').to.throw Error, 'attributes.name is required'

        it 'requires a mod version', ->
            expect(-> new ModVersion name:'Test').to.throw Error, 'attributes.version is required'

        it 'supplies default values', ->
            modVersion.description.should.equal ''
            modVersion.enabled.should.be.true
            modVersion.slug.should.equal 'test'

    describe 'addItem', ->

        it 'refuses to add duplicates', ->
            modVersion.addItem new Item name:'Wool'
            expect(-> modVersion.addItem new Item name:'Wool').to.throw Error, 'duplicate item for Wool'

        it 'adds an item indexed by its slug', ->
            modVersion.addItem new Item name:'Wool'
            modVersion._items.wool.name.should.equal 'Wool'

        it 'sets the modVersion', ->
            modVersion.addItem new Item name:'Wool'
            modVersion._items.wool.modVersion.should.equal modVersion

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
