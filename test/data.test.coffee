###
Crafting Guide - data.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Mod              = require '../src/coffee/models/mod'
ModParser        = require '../src/coffee/models/mod_parser'
ModVersion       = require '../src/coffee/models/mod_version'
ModVersionParser = require '../src/coffee/models/mod_version_parser'
fs               = require 'fs'

########################################################################################################################

describe 'data files for', ->

    for modSlug in fs.readdirSync './static/data/'
        do (modSlug)->
            describe modSlug, ->

                mod = new Mod slug:modSlug
                modParser = new ModParser model:mod, showAllErrors:true
                modParser.parse fs.readFileSync "./static/data/#{modSlug}/mod.cg", 'utf8'

                it 'loads mod.cg without errors', ->
                    modParser.errors.should.eql []
                    mod.name.should.not.equal ''
                    mod.activeModVersion.should.exist

                it 'has an icon file', ->
                    stats = fs.statSync "./static/browse/#{modSlug}/icon.png"
                    stats.isFile().should.be.true

                mod.eachModVersion (modVersion)->
                    do (modVersion)->
                        describe modVersion.version, ->

                            modVersionParser = new ModVersionParser model:modVersion, showAllErrors:true
                            fileName = "./static/data/#{modSlug}/#{modVersion.version}/mod-version.cg"
                            modVersionParser.parse fs.readFileSync fileName, 'utf8'

                            it 'loads mod-version.cg without errors', ->
                                modVersionParser.errors.should.eql []
                                _.keys(modVersion._items).length.should.be.greaterThan 0
                                _.keys(modVersion._recipes).length.should.be.greaterThan 0
