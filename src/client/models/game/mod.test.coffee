#
# Crafting Guide - mod.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Mod = require './mod'

########################################################################################################################

mod = null

########################################################################################################################

describe 'mod.coffee', ->

    beforeEach -> mod = new Mod name:'Test', slug:'test'

    describe 'compareTo', ->

        it 'lists required mods first', ->
            minecraft = new Mod name:'Minecraft', slug:'minecraft'
            mod.compareTo(minecraft).should.equal +1
            minecraft.compareTo(mod).should.equal -1

        it 'sorts by name second', ->
            buildcraft = new Mod name:'Buildcraft', slug:'buildcraft'
            mod.compareTo(buildcraft).should.equal +1
            buildcraft.compareTo(mod).should.equal -1
