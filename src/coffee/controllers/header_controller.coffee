###
Crafting Guide - header_controller.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseController   = require './base_controller'
{Duration}       = require '../constants'
{ProductionEnvs} = require '../constants'

########################################################################################################################

module.exports = class HeaderController extends BaseController

    constructor: (options={})->
        super options

    # Event Methods ################################################################################

    onLogoClicked: ->
        router.navigate '/', trigger:true
        return false

    onNavItemClicked: (event)->
        return true unless $(event.currentTarget).attr('href')?

        router.navigate $(event.currentTarget).attr('href'), trigger:true
        return false

    # BaseController Overrides #####################################################################

    render: ->
        # Overriding render because the header is already part of the stock page layout, and we
        # don't need to replace it here.
        @_rendered = true

        @$navLinks = ($(el) for el in @$('.navBar a'))

        zIndex = @$navLinks.length + 100
        for $navLink in @$navLinks
            $navLink.css 'z-index', zIndex--

        if global.env in ProductionEnvs
            addThisUrl = '//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-54f3c9717b2e530d'
            $('body').append "<script async src=\"#{addThisUrl}\"></script>"

    refresh: ->
        for $navLink in @$navLinks
            linkPage = $navLink.data('page')
            if @model is linkPage
                $navLink.addClass 'selected'
            else
                $navLink.removeClass 'selected'

                if @model.indexOf(linkPage) isnt -1
                    $navLink.find('.dot').css 'opacity': 1;
                else
                    $navLink.find('.dot').css 'opacity': 0;

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click a.logo':    'onLogoClicked'
            'click .navBar a': 'onNavItemClicked'
            'click .login a':  'routeLinkClick'
