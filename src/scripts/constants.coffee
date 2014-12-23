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

exports.Event             = Event = {}
Event.book                = {}
Event.book.load           = {}
Event.book.load.started   = 'book:load:started'   # controller, url
Event.book.load.succeeded = 'book:load:succeeded' # controller, book
Event.book.load.failed    = 'book:load:failed'    # controller, error message
Event.book.load.finished  = 'book:load:finished'  # controller
