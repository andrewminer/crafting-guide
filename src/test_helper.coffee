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

global.$       = require 'jquery'
global._       = require './common/underscore'
global.assert  = chai.assert
global.c       = require './common/constants'
global.expect  = chai.expect
global.inspect = require('util').inspect
global.should  = chai.should()
global.sinon   = require 'sinon'
global.util    = require 'util'
global.w       = require 'when'
global.ε       = 0.0001
global.π       = Math.PI

global.Backbone = Backbone = require 'backbone'
Backbone.$ = $

{Logger} = require 'crafting-guide-common'
global.logger = new Logger level:Logger.FATAL
