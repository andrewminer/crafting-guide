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

# Test Registry ########################################################################################################

mocha.setup 'bdd'

require './parser_versions/v1.test'

mocha.checkLeaks()
mocha.run()
