###
Crafting Guide - main.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

require './underscore_mixins'

views               = require './views'
Logger              = require './logger'
CraftingGuideRouter = require './crafting_guide_router'

if typeof(global) is 'undefined'
    window.global = window

global.logger = new Logger level:Logger.TRACE
global.router = new CraftingGuideRouter
global.util   = require 'util'
global.views  = views

logger.info "CraftingGuide is ready"
Backbone.history.start pushState:true
