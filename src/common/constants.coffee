#
# Crafting Guide - constants.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

exports.adsense           = adsense = {}
adsense.clientId          = 'ca-pub-6593013914878730'
adsense.skyscraper        = {}
adsense.skyscraper.height = 600
adsense.skyscraper.width  = 160
adsense.skyscraper.margin = 24
adsense.slotIds           = ['7613920409', '9574673605', '3388539204']

exports.defaultMods   = defaultMods = {}
defaultMods.minecraft = { defaultVersion: '1.7.10' } # Minecraft must be first

defaultMods.advanced_solar_panels = { defaultVersion: '3.5.1' }
defaultMods.applied_energistics_2 = { defaultVersion: 'rv1-stable-1' }
defaultMods.big_reactors          = { defaultVersion: '0.4.2A2' }
defaultMods.buildcraft            = { defaultVersion: '6.4.6' }
defaultMods.computercraft         = { defaultVersion: '1.74' }
defaultMods.enderio               = { defaultVersion: '2.2.7.325' }
defaultMods.ender_storage         = { defaultVersion: '1.4.5.29' }
defaultMods.extra_cells           = { defaultVersion: '2.2.73b129' }
defaultMods.extra_utilities       = { defaultVersion: '1.2.2' }
defaultMods.forestry              = { defaultVersion: '3.4.0.7' }
defaultMods.forge_multipart       = { defaultVersion: '1.2.0.345' }
defaultMods.galacticraft          = { defaultVersion: '3.0.12.404' }
defaultMods.hydraulicraft         = { defaultVersion: '2.1.242' }
defaultMods.ic2_classic           = { defaultVersion: 'none' }
defaultMods.industrial_craft_2    = { defaultVersion: '2.2.663' }
defaultMods.iron_chests           = { defaultVersion: '6.0.62.742' }
defaultMods.jabba                 = { defaultVersion: '1.2.1a' }
defaultMods.mekanism              = { defaultVersion: '7.1.1.127' }
defaultMods.minefactory_reloaded  = { defaultVersion: '2.8.0RC8-86' }
defaultMods.modular_powersuits    = { defaultVersion: '0.11.0-300-thermal-expansion' }
defaultMods.opencomputers         = { defaultVersion: '1.5.22' }
defaultMods.railcraft             = { defaultVersion: '9.5.0' }
defaultMods.simply_jetpacks       = { defaultVersion: '1.4.1' }
defaultMods.solar_flux            = { defaultVersion: '0.5b' }
defaultMods.storage_drawers       = { defaultVersion: '1.7.10-1.6.2' }
defaultMods.thermal_dynamics      = { defaultVersion: '1.0.0RC7-98' }
defaultMods.thermal_expansion     = { defaultVersion: '4.0.0B8-23' }

exports.duration = duration = {}
duration.snap    = 100
duration.fast    = 200
duration.normal  = 400
duration.slow    = 1200

exports.event         = event = {}
event.add             = 'add'                 # collection, item...
event.button          = {}
event.button.complete = 'button:complete'     # controller
event.button.first    = 'button:first'        # controller, buttonType
event.button.second   = 'button:second'       # controller, buttonType
event.change          = 'change'              # model
event.click           = 'click'               # event
event.load            = {}
event.load.started    = 'load:started'        # controller, url
event.load.succeeded  = 'load:succeeded'      # controller, book
event.load.failed     = 'load:failed'         # controller, error message
event.load.finished   = 'load:finished'       # controller
event.remove          = 'remove'              # collection, item...
event.request         = 'request'             # model
event.route           = 'route'
event.sort            = 'sort'
event.sync            = 'sync'                # model, response

exports.gitHub                       = gitHub = {}
gitHub.file                          = {}
gitHub.file.itemDescription          = {}
gitHub.file.itemDescription.fileName = _.template "item.cg"
gitHub.file.itemDescription.path     = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>"

exports.key   = key = {}
key.enter     = 13
key.return    = 13
key.escape    = 27
key.upArrow   = 38
key.downArrow = 40

exports.limits = limits = {}
limits.maximumGraphSize = 5000
limits.maximumPlanCount = 5000

exports.login = login = {}
login.authorizeUrl = _.template "https://github.com/login/oauth/authorize" +
    "?client_id=<%= clientId %>&scope=public_repo&state=<%= state %>"
login.clientIds =
    'local':      '20afe4dbe75464a8cf36'
    'production': 'ce71be7f66926ff6ff38'

exports.modelState  = modelState = {}
modelState.unloaded = 'unloaded'
modelState.loading  = 'loading'
modelState.loaded   = 'loaded'
modelState.failed   = 'failed'

exports.opacity = opacity = {}
opacity.hidden  = 1e-6
opacity.shown   = 1

exports.productionEnvs = [ 'staging', 'production' ]

exports.requiredMods = [ 'minecraft' ]

exports.server             = {}
exports.server.defaultPort = 8080

exports.text             = text = {}
text.browseDescription   = _.template 'Browse through complete item listings for over a dozen top mods and use the interactive crafting planner for step-by-step instructions'
text.configDescription   = _.template 'Configure the interactive crafting planner for your exact modpack and get step-by-step instructions for any item in your world'
text.craftDescription    = _.template 'Build anything in your Minecraft mod pack with a full list of materials and step-by-step instructions using our interactive crafting planner'
text.newsDescription     = _.template 'Find everything you need to know about your Minecraft mod pack and use the interactive crafting planner for step-by-step instructions and full lists of materials'
text.itemDescription     = _.template 'Make <%= itemName %> and the rest of <%= modName %> easy and use the interactive crafting planner for step-by-step instructions'
text.modDescription      = _.template 'Make <%= modName %> easy with tutorials, videos, and a full item listing along with an interactive crafting planner for step-by-step instructions'
text.title               = _.template 'Minecraft Crafting Guide'
text.titleWithText       = _.template '<%= text %> | Minecraft Crafting Guide'
text.tutorialDescription = _.template 'Learn about <%= name %> in <%= mod %> and use the interactive crafting planner to get ready for your build!'

exports.url          = url = {}
url.crafting         = _.template "/craft/<%= inventoryText %>"
url.item             = _.template "/browse/<%= modSlug %>/<%= itemSlug %>/"
url.itemData         = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>/item.cg"
url.itemIcon         = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>/icon.png"
url.itemImageDir     = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>"
url.login            = _.template "/login"
url.mod              = _.template "/browse/<%= modSlug %>/"
url.modData          = _.template "/data/<%= modSlug %>/mod.cg"
url.modIcon          = _.template "/data/<%= modSlug %>/icon.png"
url.modVersionData   = _.template "/data/<%= modSlug %>/versions/<%= modVersion %>/mod-version.cg"
url.root             = _.template "/"
url.tutorial         = _.template "/browse/<%= modSlug %>/tutorials/<%= tutorialSlug %>/"
url.tutorialData     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/tutorial.cg"
url.tutorialIcon     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/icon.png"
url.tutorialIcon     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/icon.png"
url.tutorialImageDir = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>"
