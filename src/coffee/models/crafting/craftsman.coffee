###
Crafting Guide - craftsman.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_             = require 'underscore'
BaseModel     = require '../base_model'
{Event}       = require '../../constants'
GraphBuilder  = require './graph_builder'
Inventory     = require '../inventory'
PlanBuilder   = require './plan_builder'
PlanEvaluator = require './plan_evaluator'
w             = require 'when'

########################################################################################################################

module.exports = class Craftsman extends BaseModel

    @::ANALYZE_STEP_INCREMENT = 100

    @::GRAPH_STEP_INCREMENT = 10

    @::PLAN_STEP_INCREMENT = 50

    @::STAGE =
        WAITING:   'waiting'
        GRAPHING:  'examining recipes'
        PLANNING:  'computing plans'
        ANALYZING: 'analyzing plans'
        COMPLETE:  'complete'

    constructor: (modPack)->
        if not modPack? then throw new Error 'modPack is required'
        attributes =
            paused:     false
            stage:      @STAGE.WAITING
            stageCount: 0
        super attributes, {}

        @_modPack = modPack

        reset = _.throttle (=> @reset()), 100

        @_have = new Inventory
        @_have.on Event.change, reset

        @_want = new Inventory
        @_want.on Event.change, reset

        @on Event.change + ':paused', reset
        @on Event.change + ':stage', => logger.info "Craftsman has started #{@stage}..."
        @reset()

    # Public Methods ###############################################################################

    work: ->
        return if @_want.isEmpty
        logger.verbose => "stage: #{@stage}(#{@stageCount}) working..."

        if not @_graphBuilder?
            want = new Inventory {modPack:@_modPack}, clone:@_want
            want.localize()

            have = new Inventory {modPack:@_modPack}, clone:@_have
            have.localize()

            logger.info -> "Craftsman starting to build #{want} from #{have}"

            @_graphBuilder = new GraphBuilder modPack:@_modPack, want:want, have:have
            @stage         = @STAGE.GRAPHING
            @stageCount    = 0
        else if not @_graphBuilder.complete
            @_graphBuilder.expandGraph @GRAPH_STEP_INCREMENT
            @stageCount = @_graphBuilder.stepCount
        else if not @_planBuilder?
            logger.debug => "Craftsman finished computing graph:\n#{@_graphBuilder.rootNode}"

            @_planBuilder = new PlanBuilder @_graphBuilder.rootNode, @_modPack, want:@_graphBuilder.want
            @stage        = @STAGE.PLANNING
            @stageCount   = 0
        else if not @_planBuilder.complete
            @_planBuilder.producePlans @PLAN_STEP_INCREMENT
            @stageCount = @_planBuilder.plans.length
        else if not @_planEvaluator?
            @_planEvaluator = new PlanEvaluator @_planBuilder.plans
            @stage          = @STAGE.ANALYZING
            @stageCount     = 0
        else if not @_planEvaluator.complete
            @_planEvaluator.scorePlans @ANALYZE_STEP_INCREMENT
            @stageCount = @_planEvaluator.lastScored
        else
            @_plans = [
                @_planEvaluator.findBestPlan PlanEvaluator::CRITERIA.FEWEST_STEPS
                @_planEvaluator.findBestPlan PlanEvaluator::CRITERIA.LEAST_MATERIALS
            ]
            @_plans[0].computeRequired()
            logger.info => "Craftsman has finished with plans: #{(p.toString() for p in @_plans).join('\n')}"
            @trigger Event.change + ':complete', this
            @trigger Event.change, this

        @_scheduleNextWork()
        return @complete

    reset: ->
        @_graphBuilder  = null
        @_planBuilder   = null
        @_planEvaluator = null
        @_plans         = null

        @stage      = @STAGE.WAITING
        @stageCount = 0

        @_scheduleNextWork()

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        complete:
            get: -> @_plans?

        have:
            get: -> @_have

        plan:
            get: -> @_plans?[0]

        want:
            get: -> @_want

    # Private Methods ##############################################################################

    _scheduleNextWork: ->
        return if @paused
        return if @want.isEmpty
        return if @complete

        _.defer => @work()
