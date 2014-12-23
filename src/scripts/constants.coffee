###
# Crafting Guide - constants.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

exports.Duration = Duration = {}
Duration.snap    = 100
Duration.fast    = Duration.snap * 2
Duration.normal  = Duration.fast * 2
Duration.slow    = Duration.normal * 2

exports.Opacity = Opacity = {}
Opacity.hidden  = 1e-6
Opacity.shown   = 1

exports.Event        = Event = {}
Event.change         = 'change'
Event.load           = {}
Event.load.started   = 'book:load:started'   # controller, url
Event.load.succeeded = 'book:load:succeeded' # controller, book
Event.load.failed    = 'book:load:failed'    # controller, error message
Event.load.finished  = 'book:load:finished'  # controller

exports.DefaultBookUrls = DefaultBookUrls = [
    '/data/vanilla.json'
    '/data/applied_energetics.json'
    '/data/buildcraft.json'
    '/data/gravisuite.json'
    '/data/industrial_craft.json'
    '/data/more_blocks.json'
    '/data/thermal_expansion.json'
]
