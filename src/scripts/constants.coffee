###
Crafting Guide - constants.coffee

Copyright (c) 2014 by Redwood Labs
All rights reserved.
###

exports.DefaultBookUrls = DefaultBookUrls = [
    '/data/minecraft/recipes.json'
    '/data/applied_energetics/recipes.json'
    '/data/buildcraft/recipes.json'
    '/data/gravisuite/recipes.json'
    '/data/industrial_craft/recipes.json'
    '/data/more_blocks/recipes.json'
    '/data/thermal_expansion/recipes.json'
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

exports.ImageUrl = _.template "/data/<%= modSlug %>/images/<%= itemSlug %>.png"

exports.Key = Key = {}
Key.Return = 13

exports.Opacity = Opacity = {}
Opacity.hidden  = 1e-6
Opacity.shown   = 1

exports.RequiredMods = [
    'Minecraft'
]

exports.UrlParam        = UrlParam = {}
UrlParam.quantity       = 'count'
UrlParam.recipe         = 'recipeName'
UrlParam.includingTools = 'tools'
