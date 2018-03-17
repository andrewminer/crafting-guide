#
# Crafting Guide - mod_ballot_controller.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

BaseController            = require '../../base_controller'
ModBallotLineController   = require './mod_ballot_line/mod_ballot_line_controller'
SuggestModPanelController = require './suggest_mod_panel/suggest_mod_panel_controller'

########################################################################################################################

module.exports = class ModBallotController extends BaseController

    @::LOAD_ERROR = 'Sorry! Something went wrong loading the mod list. Please try again.'

    @::MAX_VOTES = 3

    @::STATUS =
        ERROR:      'error'
        INITIAL:    'initial'
        LOADED:     'loaded'
        LOADING:    'loading'
        LOGGED_OUT: 'logged-out'

    @::VOTE_ERROR = 'Sorry! Something went wrong casting your vote. Please try again.'

    constructor: (options={})->
        if not options.client      then throw new Error 'options.client is required'
        if not options.imageLoader then throw new Error 'options.imageLoader is required'

        options.model        = ballot:null, votes:null
        options.templateName = 'browse_page/mod_ballot'
        super options

        @_client          = options.client
        @_imageLoader     = options.imageLoader
        @_lineControllers = {}
        @_status          = @STATUS.INITIAL

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        isVotingAllowed:
            get: ->
                voteCount = @model.votes?.length or 0
                return voteCount < @MAX_VOTES

        user:
            get: -> @_user

            set: (newUser)->
                @_user = newUser

    # Event Methods ################################################################################

    onReloadClicked: ->
        tracker.trackEvent c.tracking.category.modVote, 'reload'
        @_reloadData()
        return false

    onVoteButtonClicked: (controller)->
        modId = controller.model.ballotLine.modId

        if controller.model.vote?
            tracker.trackEvent c.tracking.category.modVote, 'cancel-vote', @_findModName modId
            @_cancelVote modId
        else
            tracker.trackEvent c.tracking.category.modVote, 'cast-vote', @_findModName modId
            @_castVote modId

    onVoteNowClicked: ->
        tracker.trackEvent c.tracking.category.modVote, 'vote-now'

        if not @user?
            global.site.login()
        else
            @_reloadData()

        return false

    # BaseController Overrides #####################################################################

    onDidRender: ->
        @_suggestPanelController = @addChild SuggestModPanelController, '.view__suggest_mod_panel'

        @$ballotList       = @$('.ballot-list')
        @$remainingCount   = @$('.remaining-count')
        @$remainingMessage = @$('.remaining')
        @$statusMessage    = @$('.status-message')
        @$statusSections   = @$('.status')
        super

    refresh: ->
        @_refreshLines()
        @_refreshRemaining()
        @_refreshStatus()
        super

    # Backbone.View Methods ########################################################################

    events: ->
        _.extend super,
            'click .button.reload':   'onReloadClicked'
            'click .button.vote-now': 'onVoteNowClicked'

    # Private Methods ##############################################################################

    _cancelVote: (modId)->
        controller = @_lineControllers[modId]
        vote       = @_findVote modId

        controller.isWaiting = true
        controller.tryRefresh()

        @_client.cancelVote modVoteId:vote.id
            .then =>
                @model.votes = _(@model.votes).without vote
                controller.model.vote = null
                controller.model.ballotLine.voteCount -= 1
            .catch =>
                @_changeStatus @STATUS.ERROR, @VOTE_ERROR
            .finally =>
                controller.isWaiting = false
                @tryRefresh()

    _castVote: (modId)->
        controller = @_lineControllers[modId]
        vote       = @_findVote modId

        controller.isWaiting = true
        controller.tryRefresh()

        @_client.castVote modId:modId, userId:@user.id
            .then (response)=>
                vote = response.json
                @model.votes.push vote
                controller.model.vote = vote
                controller.model.ballotLine.voteCount += 1
            .catch (error)=>
                logger.error -> "vote could not be cast: #{error}"
                @_changeStatus @STATUS.ERROR, @VOTE_ERROR
            .finally =>
                controller.isWaiting = false
                @tryRefresh()

    _computeLines: ->
        return [] unless @model.ballot?.lines?

        @model.ballot.lines.sort (a, b)->
            if a.voteCount != b.voteCount
                return if a.voteCount > b.voteCount then -1 else +1
            if a.name != b.name
                return if a.name < b.name then -1 else +1
            return 0

        return @model.ballot.lines

    _changeStatus: (status, message='')->
        @_status = status
        @_message = message

    _findVote: (modId)->
        return null unless @model.votes?

        for vote in @model.votes
            return vote if vote.modId is modId
        return null

    _findModName: (modId)->
        return '' unless @model.ballot?

        for line in @model.ballot.lines
            return line.name if line.modId is modId
        return ''

    _refreshLines: ->
        extraControllers = _.clone @_lineControllers
        lines            = @_computeLines()

        for line, index in lines
            controller = @_lineControllers[line.modId]
            delete extraControllers[line.modId]

            model = {ballotLine:line, vote:@_findVote(line.modId)}
            if not controller?
                controller = new ModBallotLineController
                    imageLoader:         @_imageLoader
                    model:               model
                    onVoteButtonClicked: (controller)=> @onVoteButtonClicked controller
                controller.render()
                @$ballotList.append controller.$el
                @_lineControllers[line.modId] = controller
            else
                controller.model = model

            controller.isVotingAllowed = @isVotingAllowed

        for modId, controller of extraControllers
            delete @_lineControllers[modId]
            controller.remove()

        _.delay (=> @_refreshLineLayout()), 100

    _refreshLineLayout: ->
        lines  = @_computeLines()
        offset = @$ballotList.offset()

        for line in lines
            controller = @_lineControllers[line.modId]
            continue unless controller?

            if controller.$el.height() is 0
                # keep trying until the elements have been created and laid out by the browser
                _.delay (=> @_refreshLineLayout()), 100
                return

            controller.$el.offset offset
            offset.top += controller.$el.outerHeight(true)

        @$ballotList.height offset.top - @$ballotList.offset().top

    _refreshRemaining: ->
        if @model.votes?
            @$remainingCount.html @MAX_VOTES - @model.votes.length
            @show @$remainingMessage
        else
            @hide @$remainingMessage

    _refreshStatus: ->
        @hide @$('.status')
        @show @$(".status.#{@_status}")
        @$statusMessage.html @_message

    _reloadBallot: ->
        return @_loadingBallot if @_loadingBallot?

        @model.ballot = null
        @_changeStatus @STATUS.LOADING, "Loading ballot data..."
        @tryRefresh()

        @_loadingBallot = @_client.getModBallot()
            .then (response)=>
                @model.ballot = response.json
                if not @user? or @model.votes? then @_changeStatus @STATUS.LOADED
                @tryRefresh()
            .catch (error)=>
                @_changeStatus @STATUS.ERROR, @LOAD_ERROR
            .finally =>
                @_loadingBallot = null

    _reloadData: ->
        @_reloadVotes()
        @_reloadBallot()

    _reloadVotes: ->
        return @_loadingVotes if @_loadingVotes?
        return unless @user?

        @model.votes = null
        @_changeStatus @STATUS.LOADING, "Loading ballot data..."
        @tryRefresh()

        @_loadingVotes = @_client.getModVotes()
            .then (response)=>
                @model.votes = response.json
                if @model.ballot? then @_changeStatus @STATUS.LOADED
                @tryRefresh()
            .catch (error)=>
                @_changeStatus @STATUS.ERROR, @LOAD_ERROR
            .finally =>
                @_loadingVotes = null
