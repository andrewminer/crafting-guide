###
# Crafting Guide - test.coffee
#
# Copyright (c) 2014-2015 by Redwood Labs
# All rights reserved.
###

# Test Set-up ##########################################################################################################

chai = require 'chai'
chai.use require 'sinon-chai'
chai.config.includeStack = true

global._        = require 'underscore'
global.Backbone = require 'backbone'
global.assert   = chai.assert
global.expect   = chai.expect
global.should   = chai.should()
global.sinon    = require 'sinon'
global.util     = require 'util'
global.w        = require 'when'

{Logger}      = require 'crafting-guide-common'
global.logger = new Logger level:Logger.DEBUG

require '../src/coffee/polyfill'
require '../src/coffee/underscore_mixins'
