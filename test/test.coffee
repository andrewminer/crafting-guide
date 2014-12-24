###
# Crafting Guide - test.coffee
#
# Copyright (c) 2014 by Redwood Labs
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

# Test Registry ########################################################################################################

mocha.setup 'bdd'

require './inventory.test'
require './inventory_parser.test'
require './recipe_book_parser.test'

mocha.checkLeaks()
mocha.run()
