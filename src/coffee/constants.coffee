###
Crafting Guide - constants.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

_ = require 'underscore'

exports.Adsense  = Adsense = {}
Adsense.clientId = 'ca-pub-6593013914878730'
Adsense.slotIds  = ['7613920409', '9574673605', '3388539204']

exports.DefaultMods =
    minecraft:             { defaultVersion: '1.7.10' } # Minecraft must be first

    advanced_solar_panels: { defaultVersion: '3.5.1' }
    agricraft:             { defaultVersion: '1.4.6' }
    applied_energistics_2: { defaultVersion: 'rv1-stable-1' }
    big_reactors:          { defaultVersion: '0.4.2A2' }
    buildcraft:            { defaultVersion: '6.4.6' }
    computercraft:         { defaultVersion: '1.74' }
    enderio:               { defaultVersion: '2.2.7.325' }
    ender_storage:         { defaultVersion: '1.4.5.29' }
    extra_cells:           { defaultVersion: '2.2.73b129' }
    extra_utilities:       { defaultVersion: '1.2.2' }
    forge_multipart:       { defaultVersion: '1.2.0.345' }
    forestry:              { defaultVersion: '3.4.0.7' }
    hydraulicraft:         { defaultVersion: '2.1.242' }
    galacticraft:          { defaultVersion: '3.0.12.404' }
    ic2_classic:           { defaultVersion: 'none' }
    industrial_craft_2:    { defaultVersion: '2.2.663' }
    iron_chests:           { defaultVersion: '6.0.62.742' }
    jabba:                 { defaultVersion: '1.2.1a' }
    mekanism:              { defaultVersion: '7.1.1.127' }
    minefactory_reloaded:  { defaultVersion: '2.8.0RC8-86' }
    modular_powersuits:    { defaultVersion: '0.11.0-300-thermal-expansion' }
    opencomputers:         { defaultVersion: '1.5.22' }
    railcraft:             { defaultVersion: '9.5.0' }
    simply_jetpacks:       { defaultVersion: '1.4.1' }
    storage_drawers:       { defaultVersion: '1.7.10-1.6.2' }
    solar_flux:            { defaultVersion: '0.5b' }
    thermal_dynamics:      { defaultVersion: '1.0.0RC7-98' }
    thermal_expansion:     { defaultVersion: '4.0.0B8-23' }

exports.Duration = Duration = {}
Duration.snap    = 100
Duration.fast    = 200
Duration.normal  = 400
Duration.slow    = 1200

exports.Event             = Event = {}
Event.add                 = 'add'                 # collection, item...
Event.animate             = {}
Event.animate.hide        = {}
Event.animate.hide.start  = 'animate:hide:start'  # controller, selector
Event.animate.hide.finish = 'animate:hide:finish' # controller, selector
Event.animate.show        = {}
Event.animate.show.start  = 'animate:show:start'  # controller, selector
Event.animate.show.finish = 'animate:show:finish' # controller, selector
Event.button              = {}
Event.button.complete     = 'button:complete'     # controller
Event.button.first        = 'button:first'        # controller, buttonType
Event.button.second       = 'button:second'       # controller, buttonType
Event.change              = 'change'              # model
Event.click               = 'click'               # event
Event.load                = {}
Event.load.started        = 'load:started'        # controller, url
Event.load.succeeded      = 'load:succeeded'      # controller, book
Event.load.failed         = 'load:failed'         # controller, error message
Event.load.finished       = 'load:finished'       # controller
Event.remove              = 'remove'              # collection, item...
Event.request             = 'request'             # model
Event.route               = 'route'
Event.sort                = 'sort'
Event.sync                = 'sync'                # model, response
Event.transitionEnd       = (->
    return 'transitionend' unless document?
    transitions =
      'WebkitTransition': 'webkitTransitionEnd'
      'MozTransition':    'transitionend'
      'MSTransition':     'msTransitionEnd'
      'OTransition':      'oTransitionEnd'
      'transition':       'transitionend'

    el = document.createElement 'fakeelement'
    for styleName, eventName of transitions
        return eventName if el.style[styleName]?

    throw new Error 'cannot determine transitionEnd event'
)()

exports.Key   = Key = {}
Key.Enter     = 13
Key.Return    = 13
Key.Escape    = 27
Key.UpArrow   = 38
Key.DownArrow = 40

exports.GitHub                       = GitHub = {}
GitHub.file                          = {}
GitHub.file.itemDescription          = {}
GitHub.file.itemDescription.fileName = _.template "item.cg"
GitHub.file.itemDescription.path     = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>"

exports.Limits = Limits = {}
Limits.maximumGraphSize = 5000
Limits.maximumPlanCount = 5000

exports.Login = Login = {}
Login.authorizeUrl = _.template "https://github.com/login/oauth/authorize" +
    "?client_id=<%= clientId %>&scope=public_repo&state=<%= state %>"
Login.clientIds =
    'local':      'a2a1c5f1bb2d7bd14ebb'
    'staging':    '655a38cde23040283361'
    'production': 'ea419abd2ab96c708815'

exports.ModelState  = ModelState = {}
ModelState.unloaded = 'unloaded'
ModelState.loading  = 'loading'
ModelState.loaded   = 'loaded'
ModelState.failed   = 'failed'

exports.Opacity = Opacity = {}
Opacity.hidden  = 1e-6
Opacity.shown   = 1

exports.ProductionEnvs = [ 'staging', 'production' ]

exports.RequiredMods = [ 'minecraft' ]

exports.Text           = Text = {}
Text.browseDescription = _.template 'Browse through complete item listings for over a dozen top mods and use the interactive crafting planner for step-by-step instructions'
Text.configDescription = _.template 'Configure the interactive crafting planner for your exact modpack and get step-by-step instructions for any item in your world'
Text.craftDescription  = _.template 'Build anything in your Minecraft mod pack with a full list of materials and step-by-step instructions using our interactive crafting planner'
Text.homeDescription   = _.template 'Find everything you need to know about your Minecraft mod pack and use the interactive crafting planner for step-by-step instructions and full lists of materials'
Text.itemDescription   = _.template 'Make <%= itemName %> and the rest of <%= modName %> easy and use the interactive crafting planner for step-by-step instructions'
Text.modDescription    = _.template 'Make <%= modName %> easy with tutorials, videos, and a full item listing along with an interactive crafting planner for step-by-step instructions'
Text.title             = _.template 'Minecraft Crafting Guide'
Text.titleWithText     = _.template '<%= text %> | Minecraft Crafting Guide'

exports.Url          = Url = {}
Url.crafting         = _.template "/craft/<%= inventoryText %>"
Url.item             = _.template "/browse/<%= modSlug %>/<%= itemSlug %>/"
Url.itemData         = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>/item.cg"
Url.itemImageDir     = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>"
Url.itemIcon         = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>/icon.png"
Url.login            = _.template "/login"
Url.mod              = _.template "/browse/<%= modSlug %>/"
Url.modData          = _.template "/data/<%= modSlug %>/mod.cg"
Url.modIcon          = _.template "/data/<%= modSlug %>/icon.png"
Url.modVersionData   = _.template "/data/<%= modSlug %>/versions/<%= modVersion %>/mod-version.cg"
Url.root             = _.template "/"
Url.tutorial         = _.template "/browse/<%= modSlug %>/tutorials/<%= tutorialSlug %>/"
Url.tutorialData     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/tutorial.cg"
Url.tutorialIcon     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/icon.png"
Url.tutorialIcon     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/icon.png"
Url.tutorialImageDir = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>"

exports.UrlParam        = UrlParam = {}
UrlParam.quantity       = 'count'
UrlParam.recipe         = 'recipeName'
UrlParam.includingTools = 'tools'
