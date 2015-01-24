###
Crafting Guide - constants.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

# Minecraft must be first
exports.DefaultMods = [
    'minecraft',
    'applied_energistics_2',
    'buildcraft',
    'industrial_craft_2',
    'thermal_expansion',
]

exports.Duration = Duration = {}
Duration.snap    = 100
Duration.fast    = Duration.snap * 2
Duration.normal  = Duration.fast * 2
Duration.slow    = Duration.normal * 2

exports.Event        = Event = {}
Event.add            = 'add'            # collection, item...
Event.change         = 'change'         # model
Event.load           = {}
Event.load.started   = 'load:started'   # controller, url
Event.load.succeeded = 'load:succeeded' # controller, book
Event.load.failed    = 'load:failed'    # controller, error message
Event.load.finished  = 'load:finished'  # controller
Event.remove         = 'remove'         # collection, item...
Event.request        = 'request'        # model
Event.route          = 'route'
Event.sort           = 'sort'
Event.sync           = 'sync'           # model, response

exports.Key = Key = {}
Key.Return = 13

exports.Opacity = Opacity = {}
Opacity.hidden  = 1e-6
Opacity.shown   = 1

exports.RequiredMods = [ 'minecraft' ]

exports.ModelState  = ModelState = {}
ModelState.unloaded = 'unloaded'
ModelState.loading  = 'loading'
ModelState.loaded   = 'loaded'
ModelState.failed   = 'failed'

exports.Url    = Url = {}
Url.itemIcon   = _.template "/data/<%= modSlug %>/<%= modVersion %>/images/<%= slug %>.png"
Url.item       = _.template "/item/<%= slug %>"
Url.mod        = _.template "/mod/<%= modSlug %>"
Url.modData    = _.template "/data/<%= modSlug %>/mod.cg"
Url.modVersion = _.template "/data/<%= modSlug %>/<%= modVersion %>/mod-version.cg"

exports.UrlParam        = UrlParam = {}
UrlParam.quantity       = 'count'
UrlParam.recipe         = 'recipeName'
UrlParam.includingTools = 'tools'
