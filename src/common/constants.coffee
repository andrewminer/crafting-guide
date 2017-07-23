#
# Crafting Guide - constants.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require "./underscore"
_.extend exports, require("crafting-guide-common").constants

########################################################################################################################

exports.adsense                    = adsense = {}
adsense.adTypeMap                  = desktop:'skyscraper', tablet:'leaderboard', mobile:'largeMobileBanner'
adsense.clientId                   = 'ca-pub-6593013914878730'
adsense.largeMobileBanner          = {}
adsense.largeMobileBanner.cssClass = 'large-mobile-banner'
adsense.largeMobileBanner.height   = 100 # px
adsense.largeMobileBanner.slotIds  = ['6651071600', '2081271209', '3558004401']
adsense.largeMobileBanner.width    = 320 # px
adsense.leaderboard                = {}
adsense.leaderboard.cssClass       = 'leaderboard'
adsense.leaderboard.height         = 90 # px
adsense.leaderboard.slotIds        = ['6790672401', '8267405609', '5174338406']
adsense.leaderboard.width          = 728 # px
adsense.minimumDistance            = 100 # px
adsense.readinessCheckInterval     = 1000 # ms
adsense.skyscraper                 = {}
adsense.skyscraper.cssClass        = 'skyscraper'
adsense.skyscraper.height          = 600 # px
adsense.skyscraper.margin          = 24 # px
adsense.skyscraper.slotIds         = ['7613920409', '9574673605', '3388539204']
adsense.skyscraper.width           = 160 # px

exports.defaultMods   = defaultMods = {}
defaultMods.minecraft = { defaultVersion: '1.7.10' } # Minecraft must be first

defaultMods.advanced_solar_panels = { defaultVersion: '3.5.1' }
defaultMods.agricraft             = { defaultVersion: '1.7.10_1.5.0' }
defaultMods.applied_energistics_2 = { defaultVersion: 'rv1-stable-1' }
defaultMods.big_reactors          = { defaultVersion: '0.4.2A2' }
defaultMods.buildcraft            = { defaultVersion: '1.7.18' }
defaultMods.computercraft         = { defaultVersion: '1.74' }
defaultMods.draconic_evolution    = { defaultVersion: '1.0.2h' }
defaultMods.ender_storage         = { defaultVersion: '1.4.5.29' }
defaultMods.enderio               = { defaultVersion: '2.2.7.325' }
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
defaultMods.logistics_pipes       = { defaultVersion: '0.9.3.100' }
defaultMods.mekanism              = { defaultVersion: '7.1.1.127' }
defaultMods.minefactory_reloaded  = { defaultVersion: '2.8.0RC8-86' }
defaultMods.modular_powersuits    = { defaultVersion: '0.11.0-300-thermal-expansion' }
defaultMods.opencomputers         = { defaultVersion: '1.5.22' }
defaultMods.quantum_flux          = { defaultVersion: '1.3.4' }
defaultMods.project_red           = { defaultVersion: '4.5.16.77' }
defaultMods.redstone_arsenal      = { defaultVersion: '9.5.0' }
defaultMods.railcraft             = { defaultVersion: '9.5.0' }
defaultMods.simply_jetpacks       = { defaultVersion: '1.4.1' }
defaultMods.solar_expansion       = { defaultVersion: '1.6a' }
defaultMods.solar_flux            = { defaultVersion: '0.5b' }
defaultMods.storage_drawers       = { defaultVersion: '1.7.10-1.6.2' }
defaultMods.thermal_dynamics      = { defaultVersion: '1.7.10r1.2.0' }
defaultMods.thermal_expansion     = { defaultVersion: '1.7.10r4.1.4' }
defaultMods.thermal_foundation    = { defaultVersion: '1.7.10r1.2.5' }
defaultMods.tinkers_construct     = { defaultVersion: '1.7.10-1.8.8' }

exports.duration = duration = {}
duration.snap    = 100
duration.fast    = 200
duration.normal  = 400
duration.slow    = 1200

exports.gitHub                       = gitHub = {}
gitHub.file                          = {}
gitHub.file.itemDescription          = {}
gitHub.file.itemDescription.fileName = _.template "item.json"
gitHub.file.itemDescription.path     = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>"

exports.key   = key = {}
key.enter     = 13
key.return    = 13
key.escape    = 27
key.upArrow   = 38
key.downArrow = 40

exports.login = login = {}
login.authorizeUrl = _.template "https://github.com/login/oauth/authorize" +
    "?client_id=<%= clientId %>&scope=public_repo&state=<%= state %>"
login.clientIds =
    'local':      '20afe4dbe75464a8cf36'
    'staging':    '3d75ed772ce5004180d6'
    'production': 'ce71be7f66926ff6ff38'

exports.opacity = opacity = {}
opacity.hidden  = 1e-6
opacity.shown   = 1

exports.productionEnvs = [ 'staging', 'production' ]

exports.requiredMods = [ 'minecraft' ]

exports.screen = screen = {}
screen.mobileMaxWidth = 568 # px
screen.tabletMaxWidth = 960 # px
screen.type = {}
screen.type.desktop = 'desktop'
screen.type.mobile = 'mobile'
screen.type.tablet = 'tablet'

screen.type.compute = ->
    width = $(document).width()
    return screen.type.mobile if width <= screen.mobileMaxWidth
    return screen.type.tablet if width <= screen.tabletMaxWidth
    return screen.type.desktop

exports.server             = {}
exports.server.defaultPort = 4347

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

exports.tracking             = tracking = {}
tracking.category            = {}
tracking.category.account    = 'account'
tracking.category.craft      = 'craft'
tracking.category.craftHave  = 'craft-have'
tracking.category.craftNeed  = 'craft-need'
tracking.category.craftWant  = 'craft-want'
tracking.category.feedback   = 'feedback'
tracking.category.markdown   = 'markdown'
tracking.category.modPack    = 'mod-pack'
tracking.category.modVote    = 'mod-vote'
tracking.category.multiblock = 'multiblock'
tracking.category.navigate   = 'navigate'
tracking.category.search     = 'search'
