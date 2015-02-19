###
# Crafting Guide - test.coffee
#
# Copyright (c) 2014-2015 by Redwood Labs
# All rights reserved.
###

# Test Set-up ##########################################################################################################

chai.use require 'sinon-chai'
chai.config.includeStack = true

if typeof(global) is 'undefined'
    window.global = window

global.assert = chai.assert
global.expect = chai.expect
global.should = chai.should()
global.util   = require 'util'

Logger = require '../src/scripts/logger'
global.logger = new Logger level:Logger.DEBUG

require '../src/scripts/polyfill'
require '../src/scripts/underscore_mixins'

# Test Registry ########################################################################################################

mocha.setup 'bdd'

# tests are roughly in order of how errors should be tackled
require './string_builder.test'
require './item_slug.test'
require './inventory.test'
require './recipe.test'
require './mod_version.test'
require './mod.test'
require './mod_pack.test'
require './parser_versions/mod_version_parser_v1.test'
require './crafting_plan.test'

mocha.checkLeaks()
mocha.globals ['LiveReload']
mocha.run()
