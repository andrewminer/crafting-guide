###
Crafting Guide - mod.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Mod = require '../src/scripts/models/mod'

########################################################################################################################

mod = null

########################################################################################################################

describe 'Mod', ->

    beforeEach -> mod = new Mod name:'Test'

    describe 'compareTo', ->

        it 'lists required mods first', ->
            minecraft = new Mod name:'Minecraft'
            mod.compareTo(minecraft).should.equal +1
            minecraft.compareTo(mod).should.equal -1

        it 'sorts by name second', ->
            buildcraft = new Mod name:'Buildcraft'
            mod.compareTo(buildcraft).should.equal +1
            buildcraft.compareTo(mod).should.equal -1
