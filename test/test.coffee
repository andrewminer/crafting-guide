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

Logger = require '../src/scripts/logger'
global.logger = new Logger level:Logger.TRACE

require '../src/scripts/underscore_mixins'

# Test Registry ########################################################################################################

mocha.setup 'bdd'

require './crafting_plan.test'
require './inventory.test'
require './inventory_parser.test'
require './mod_pack.test'
require './mod_version.test'
require './mod_version_parsers/v1.test'

mocha.checkLeaks()
mocha.globals ['LiveReload']
mocha.run()
