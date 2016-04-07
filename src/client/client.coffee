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
marked.setOptions sanitize:true

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
    when 'staging.crafting-guide.com'
        global.env   = 'staging'
        logger.level = Logger.VERBOSE
        apiBaseUrl   = 'http://api-staging.crafting-guide.com'
    when 'crafting-guide.com'
        global.env   = 'production'
        logger.level = Logger.INFO
        apiBaseUrl   = 'http://api.crafting-guide.com'
    else
        throw new Error "cannot determine the environment of: #{window.location.hostname}"

########################################################################################################################

Storage = require './storage'
storage = new Storage storage:global.localStorage

########################################################################################################################

{CraftingGuideClient} = require 'crafting-guide-common'
client = _(new CraftingGuideClient(baseUrl:apiBaseUrl)).extend Backbone.Events
client.onStatusChanged = (client, oldStatus, newStatus)->
    logger.info "Crafting Guide server status changed from #{oldStatus} to #{newStatus}"
    client.trigger 'change:status', client, oldStatus, newStatus
    client.trigger 'change', client

client.checkStatus()

########################################################################################################################

SiteController = require './site/site_controller'
global.site = site = new SiteController client:client, storage:storage
site.render()
site.loadDefaultModPack()
site.loadCurrentUser()

Backbone.history.start pushState:true
logger.info -> "CraftingGuide is ready"
