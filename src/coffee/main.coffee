###
Crafting Guide - main.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

require './underscore_mixins'
require './polyfill'

CraftingGuideRouter   = require './crafting_guide_router'
FeedbackController    = require './controllers/feedback_controller'
views                 = require './views'
{CraftingGuideClient} = require 'crafting-guide-common'
{Logger}              = require 'crafting-guide-common'

########################################################################################################################

if typeof(global) is 'undefined'
    window.global = window
    global = window.global

global.logger = new Logger

switch window.location.hostname
    when 'local.crafting-guide.com'
        global.env   = 'local'
        logger.level = Logger.DEBUG
        apiBaseUrl   = 'http://local.crafting-guide.com:8001'
    when 'new.crafting-guide.com'
        global.env   = 'staging'
        logger.level = Logger.VERBOSE
        apiBaseUrl   = 'https://crafting-guide-production.herokuapp.com'
    when 'crafting-guide.com'
        global.env   = 'production'
        logger.level = Logger.INFO
        apiBaseUrl   = 'https://crafting-guide-production.herokuapp.com'
    else
        throw new Error "cannot determine the environment of: #{window.location.hostname}"

client = _.extend new CraftingGuideClient(baseUrl:apiBaseUrl), Backbone.Events
client.onStatusChanged = (c, oldStatus, newStatus)->
    logger.info "Crafting Guide server status changed from #{oldStatus} to #{newStatus}"
    client.trigger 'change:status', client, oldStatus, newStatus
    client.trigger 'change', client
client.checkStatus()

global.router   = new CraftingGuideRouter client:client
global.util     = require 'util'
global.views    = views
global.markdown = global.markdown.markdown

global.feedbackController = new FeedbackController el:'.view__feedback'
feedbackController.render()

global.router.loadCurrentUser()
global.router.loadDefaultModPack()

logger.info -> "CraftingGuide is ready"
Backbone.history.start pushState:true
