###
Crafting Guide - main.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

require './underscore_mixins'
require './polyfill'

CraftingGuideRouter = require './crafting_guide_router'
FeedbackController  = require './controllers/feedback_controller'
views               = require './views'
{Logger}            = require 'crafting-guide-common'

########################################################################################################################

if typeof(global) is 'undefined'
    window.global = window
    global = window.global

global.logger = new Logger

switch window.location.hostname
    when 'localhost'
        global.env = 'development'
        logger.level = Logger.DEBUG
    when 'new.crafting-guide.com'
        global.env = 'staging'
        logger.level = Logger.VERBOSE
    when 'crafting-guide.com'
        global.env = 'production'
        logger.level = Logger.INFO

global.router   = new CraftingGuideRouter
global.util     = require 'util'
global.views    = views
global.markdown = global.markdown.markdown

global.feedbackController = new FeedbackController el:'.view__feedback'
feedbackController.render()

global.router.loadDefaultModPack()

logger.info -> "CraftingGuide is ready"
Backbone.history.start pushState:true
