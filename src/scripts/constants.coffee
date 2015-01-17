###
Crafting Guide - constants.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

exports.DefaultModVersions = [
    # Current version of Minecraft must be first
    { name:'Minecraft', version:'1.7.10' }

    { name:'Applied Energistics 2', version:'rv1-stable-1' }
    { name:'Buildcraft', version:'6.2.6' }
    { name:'IC2 Classic', version:'1.111.170-lf' }
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

exports.RequiredMods = [
    'Minecraft'
]

exports.ModelState  = ModelState = {}
ModelState.unloaded = 'unloaded'
ModelState.loading  = 'loading'
ModelState.loaded   = 'loaded'
ModelState.failed   = 'failed'

exports.Url    = Url = {}
Url.itemIcon   = _.template "/data/<%= modSlug %>/<%= modVersion %>/images/<%= slug %>.png"
Url.item       = _.template "/item/<%= encodeURIComponent(itemName) %>"
Url.mod        = _.template "/data/<%= modSlug %>/mod.cg"
Url.modVersion = _.template "/data/<%= modSlug %>/<%= modVersion %>/mod-version.cg"

exports.UrlParam        = UrlParam = {}
UrlParam.quantity       = 'count'
UrlParam.recipe         = 'recipeName'
UrlParam.includingTools = 'tools'
