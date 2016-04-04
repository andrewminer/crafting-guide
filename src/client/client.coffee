#
# Crafting Guide - client.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

############################################################################################################

# Allow Node.js-style `global` in addition to `window`
if typeof(global) is 'undefined'
    window.global = window

global._  = require '../common/underscore'
global.$  = require 'jquery'
global.c  = require '../common/constants'
global.π  = Math.PI
global.ε  = 0.0001
global.w  = require 'when'

global.Backbone = Backbone = require 'backbone'
Backbone.$ = $

{Logger} = require 'crafting-guide-common'
global.logger = new Logger

marked = require 'marked'
marked.setOptions
    sanitize: true

########################################################################################################################

global.hostName = window.location.hostname
switch global.hostName
    when 'prerender.crafting-guide.com'
        global.env   = 'prerender'
        logger.level = Logger.FATAL
        apiBaseUrl   = 'http://local.crafting-guide.com:8001'
    when 'local.crafting-guide.com', 'localhost'
        global.env   = 'local'
        logger.level = Logger.DEBUG
        apiBaseUrl   = 'http://local.crafting-guide.com:8001'
    when 'new.crafting-guide.com'
        global.env   = 'staging'
        logger.level = Logger.VERBOSE
        apiBaseUrl   = 'https://crafting-guide-staging.herokuapp.com'
    when 'crafting-guide.com'
        global.env   = 'production'
        logger.level = Logger.INFO
        apiBaseUrl   = 'https://crafting-guide-production.herokuapp.com'
    else
        throw new Error "cannot determine the environment of: #{window.location.hostname}"

########################################################################################################################

{CraftingGuideClient} = require 'crafting-guide-common'
client = _.extend new CraftingGuideClient(baseUrl:apiBaseUrl), Backbone.Events
client.onStatusChanged = (c, oldStatus, newStatus)->
    logger.info "Crafting Guide server status changed from #{oldStatus} to #{newStatus}"
    client.trigger 'change:status', client, oldStatus, newStatus
    client.trigger 'change', client
client.checkStatus()

########################################################################################################################

SiteController = require './site/site_controller'
global.site = site = new SiteController client: client
site.render()
site.loadDefaultModPack()
site.loadCurrentUser()

Backbone.history.start pushState:true
logger.info -> "CraftingGuide is ready"
