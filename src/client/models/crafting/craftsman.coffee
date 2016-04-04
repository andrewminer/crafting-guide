#
# Crafting Guide - craftsman.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel     = require '../base_model'
GraphBuilder  = require './graph_builder'
Inventory     = require '../game/inventory'
PlanBuilder   = require './plan_builder'
PlanEvaluator = require './plan_evaluator'

########################################################################################################################

module.exports = class Craftsman extends BaseModel

    @::ANALYZE_STEP_INCREMENT = 29

    @::GRAPH_STEP_INCREMENT = 59

    @::PLAN_STEP_INCREMENT = 39

    @::STAGE =
        WAITING:   'waiting'
        GRAPHING:  'examining recipes'
        PLANNING:  'computing plans'
        ANALYZING: 'analyzing plans'
        COMPLETE:  'complete'
        INVALID:   'invalid'

    constructor: (modPack)->
        if not modPack? then throw new Error 'modPack is required'
        attributes =
            paused:     false
            stage:      @STAGE.WAITING
            stageCount: 0
        super attributes, {}

        @_modPack = modPack

        reset = _.debounce (=> @reset()), 100
        reevaluatePlans = _.debounce (=> @reevaluatePlans()), 100

        @_have = new Inventory modPack:@_modPack
        @_have.on c.event.change, reevaluatePlans

        @_want = new Inventory modPack:@_modPack
        @_want.on c.event.change, reset

        @on c.event.change + ':paused', reset
        @on c.event.change + ':stage', => logger.info "Craftsman has started #{@stage}..."
        @on 'scheduleNextWork', => @_scheduleNextWork()
        @reset()

    # Public Methods ###############################################################################

    reevaluatePlans: ->
        @_plans         = null
        @_planEvaluator = null
        @stage          = @STAGE.WAITING
        @stageCount     = 0

        @_scheduleNextWork()

    reset: ->
        @_graphBuilder  = null
        @_planBuilder   = null
        @_planEvaluator = null
        @_plans         = null

        @stage      = @STAGE.WAITING
        @stageCount = 0

        @_scheduleNextWork()

    work: ->
        return if @_want.isEmpty

        if not @_graphBuilder?
            @_want.localize()
            @_have.localize()
            logger.info -> "Craftsman starting to build #{@_want} from #{@_have}"

            @_graphBuilder = new GraphBuilder modPack:@_modPack, want:@_want, have:@_have
            @stage         = @STAGE.GRAPHING
            @stageCount    = 0
        else if not @_graphBuilder.complete
            @_graphBuilder.expandGraph @GRAPH_STEP_INCREMENT
            @stageCount = @_graphBuilder.stepCount
            logger.verbose => "Craftsman is expanding graph: #{@stageCount} nodes"
        else if not @_graphBuilder.rootNode.valid
            @stage = @STAGE.INVALID
            @stageCount = 0
            logger.warning => "Craftsman could not complete a crafting plan."
        else if not @_planBuilder?
            logger.debug => "Craftsman finished computing graph:\n#{@_graphBuilder.rootNode}"
            @_planBuilder = new PlanBuilder @_graphBuilder.rootNode, @_modPack, have:@_have, want:@_want
            @stage        = @STAGE.PLANNING
            @stageCount   = 0
        else if not @_planBuilder.complete
            @_planBuilder.producePlans @PLAN_STEP_INCREMENT
            @stageCount = @_planBuilder.plans.length
            logger.verbose => "Craftsman is producing plans: #{@_planBuilder.plans.length} plans"
        else if not @_planEvaluator?
            logger.verbose => "Craftsman finished producing plans: #{@_planBuilder.plans.length} plans"
            @_planEvaluator = new PlanEvaluator @_planBuilder.plans
            @stage          = @STAGE.ANALYZING
            @stageCount     = 0
        else if not @_planEvaluator.complete
            @_planEvaluator.scorePlans @ANALYZE_STEP_INCREMENT
            @stageCount = @_planEvaluator.lastScored
            logger.verbose => "Craftsman is rating plans: #{@stageCount} plans"
        else
            @_plans = [
                @_planEvaluator.findBestPlan PlanEvaluator::CRITERIA.FEWEST_STEPS
                @_planEvaluator.findBestPlan PlanEvaluator::CRITERIA.LEAST_MATERIALS
            ]
            @stage = @STAGE.COMPLETE
            @stageCount = 0

            logger.info => "Craftsman has finished with plans: #{(p.toString() for p in @_plans).join('\n\n')}"

        @trigger c.event.change, this
        @trigger 'scheduleNextWork'
        return @complete

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        complete:
            get: -> @stage in [@STAGE.COMPLETE, @STAGE.INVALID]

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
