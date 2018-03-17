#
# Crafting Guide - client.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

global.Backbone = require 'backbone'
global._        = require './common/underscore'
global.c        = require './common/constants'

module.exports =
    constants:        require './common/constants'
    Mod:              require './client/models/game/mod'
    ModParser:        require './client/models/parsing/mod_parser'
    ModVersion:       require './client/models/game/mod_version'
    ModVersionParser: require './client/models/parsing/mod_version_parser'
