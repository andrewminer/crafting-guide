#
# Crafting Guide - client.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

############################################################################################################

# Allow Node.js-style `global` in addition to `window`
if typeof(global) is "undefined"
    window.global = window

global._  = require "../common/underscore"
global.$  = require "jquery"
global.c  = require "../common/constants"
global.π  = Math.PI
global.ε  = 0.0001
global.w  = require "when"

{Logger} = require("crafting-guide-common").util
global.logger = new Logger

Tracker = require "./tracker"
global.tracker = new Tracker

marked = require "marked"
marked.setOptions sanitize:true

global.Backbone = Backbone = require "backbone"
Backbone.$ = $

########################################################################################################################

global.hostName = window.location.hostname
switch global.hostName
    when "prerender.crafting-guide.com"
        global.env   = "prerender"
        logger.level = Logger.FATAL
        apiBaseUrl   = "http://prerender.crafting-guide.com:4347"
    when "local.crafting-guide.com", "localhost"
        global.env   = "local"
        logger.level = Logger.DEBUG
        apiBaseUrl   = "http://#{global.hostName}:4347"
    when "staging.crafting-guide.com"
        global.env   = "staging"
        logger.level = Logger.VERBOSE
        apiBaseUrl   = "http://api-staging.crafting-guide.com"
    when "crafting-guide.com"
        global.env      = "production"
        logger.level    = Logger.INFO
        tracker.enabled = true
        apiBaseUrl      = "http://api.crafting-guide.com"
    else
        throw new Error "cannot determine the environment of: #{window.location.hostname}"

########################################################################################################################

Storage = require "./storage"
storage = new Storage storage:global.localStorage

########################################################################################################################

tracker.trackPageView()

{CraftingGuideClient} = require("crafting-guide-common").api
client = _(new CraftingGuideClient(baseUrl:apiBaseUrl)).extend Backbone.Events
client.onStatusChanged = (client, oldStatus, newStatus)->
    logger.info "Crafting Guide server status changed from #{oldStatus} to #{newStatus}"
    client.trigger "change:status", client, oldStatus, newStatus
    client.trigger "change", client

client.startMonitoringStatus()

########################################################################################################################

{http, ModPackStore, ItemDetailStore} = require("crafting-guide-common").api
storeOptions = http:http, baseUrl:"#{location.protocol}//#{location.hostname}:#{location.port}"
global.stores =
    modPack:    new ModPackStore storeOptions
    itemDetail: new ItemDetailStore storeOptions

########################################################################################################################

global.stores.modPack.load c.modPacks.default
    .then (modPack)->
        SiteController = require "./site/site_controller"
        global.site = site = new SiteController client:client, storage:storage, modPack:modPack
        site.render()
        site.loadCurrentUser()

        Backbone.history.start pushState:true
        logger.info -> "CraftingGuide is ready"
