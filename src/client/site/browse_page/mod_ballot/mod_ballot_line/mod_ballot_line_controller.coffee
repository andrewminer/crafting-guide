#
# Crafting Guide - mod_ballot_line_controller.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseController = require '../../../base_controller'

########################################################################################################################

module.exports = class ModBallotLineController extends BaseController

    constructor: (options={})->
        options.templateName = 'browse_page/mod_ballot/mod_ballot_line'
        super options

        @_onVoteButtonClicked = options.onVoteButtonClicked or (controller)-> # do nothing

    # Event Methods ################################################################################

    onButtonClicked: ->
        return if @$button.hasClass 'disabled'

        @_onVoteButtonClicked this
        return false

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        isVotingAllowed:
            get: -> @_isVotingAllowed

            set: (isVotingAllowed)->
                @_isVotingAllowed = !! isVotingAllowed
                @tryRefresh()

        isWaiting:
            get: -> @_isWaiting

            set: (isWaiting)->
                @_isWaiting = !! isWaiting
                @tryRefresh()

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @$button    = @$('.button')
        @$image     = @$('img')
        @$name      = @$('.name')
        @$voteCount = @$('.vote-count')
        @$wait      = @$('.wait')
        super

    refresh: ->
        @$name.html @model.ballotLine?.name or ''
        @$voteCount.html @model.ballotLine?.voteCount or ''
        @_refreshVoteButton()
        super

    # Backbone.View Overrides ######################################################################

    events: ->
        return _.extend super,
            'click .button': 'onButtonClicked'

    # Private Methods ##############################################################################

    _refreshVoteButton: ->
        if @isWaiting
            @$wait.removeClass 'hidden'
            @$button.addClass 'hidden'
        else
            @$wait.addClass 'hidden'
            @$button.removeClass 'hidden'

        if @model.vote?
            @$button.addClass 'active'
        else
            @$button.removeClass 'active'

            if @isVotingAllowed
                @$button.removeClass 'disabled'
            else
                @$button.addClass 'disabled'
