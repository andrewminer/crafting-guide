#
# Crafting Guide - footer_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController   = require '../base_controller'

########################################################################################################################

module.exports = class FooterController extends BaseController

    constructor: (options={})->
        options.templateName = 'footer'
        super options
