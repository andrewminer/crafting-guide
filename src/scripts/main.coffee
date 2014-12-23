###
# Crafting Guide - main.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

views               = require './views'
Logger              = require './logger'
CraftingGuideRouter = require './crafting_guide_router'

if typeof(global) is 'undefined'
    window.global = window

global.views = views
global.logger = new Logger level:Logger.TRACE
global.router = new CraftingGuideRouter

logger.info "CraftingGuide is ready"
Backbone.history.start pushState:true
