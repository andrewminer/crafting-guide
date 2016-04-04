#
# Crafting Guide - fs.extensions.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fs   = require 'fs'
path = require 'path'

########################################################################################################################

fs.rmdirRfSync ?= (filePath)->
    stat = fs.statSync filePath
    if stat.isDirectory()
        for childFileName in fs.readdirSync filePath
            fs.rmdirRfSync path.join filePath, childFileName
        fs.rmdirSync filePath
    else
        fs.unlinkSync filePath

module.exports = fs
