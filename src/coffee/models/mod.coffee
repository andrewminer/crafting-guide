###
Crafting Guide - mod.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

BaseModel      = require './base_model'
{Event}        = require '../constants'
{RequiredMods} = require '../constants'
{Url}          = require '../constants'

########################################################################################################################

module.exports = class Mod extends BaseModel

    constructor: (attributes={}, options={})->
        if not attributes.slug? then throw new Error 'attributes.slug is required'

        attributes.author           ?= ''
        attributes.description      ?= ''
        attributes.documentationUrl ?= null
        attributes.downloadUrl      ?= null
        attributes.homePageUrl      ?= null
        attributes.modPack          ?= null
        attributes.name             ?= ''

        super attributes, options

        @_activeModVersion = null
        @_activeVersion    = null
        @_modVersions      = []
        @_tutorials        = []

        @once Event.sync, => @_verifyActiveModVersion()

    # Class Methods ##################################################################################

    @Version: Version =
        None: 'none'
        Latest: 'latest'

    # Public Methods #################################################################################

    compareTo: (that)->
        thisRequired = this.slug in RequiredMods
        thatRequired = that.slug in RequiredMods

        if thisRequired isnt thatRequired
            return -1 if thisRequired
            return +1 if thatRequired
        else if this.slug isnt that.slug
            return if this.slug < that.slug then -1 else +1

        return 0

    # ModVersion Proxy Methods #####################################################################

    eachItem: (callback)->
        effectiveModVersion = @_activeModVersion or @getModVersion Mod.Version.Latest
        effectiveModVersion.eachItem callback

    eachName: (callback)->
        effectiveModVersion = @_activeModVersion or @getModVersion Mod.Version.Latest
        effectiveModVersion.eachName callback

    eachRecipe: (callback)->
        effectiveModVersion = @_activeModVersion or @getModVersion Mod.Version.Latest
        effectiveModVersion.eachRecipe callback

    findItem: (slug, options={})->
        options.includeDisabled ?= false
        options.enableAsNeeded  ?= false

        if not options.includeDisabled
            return unless @_activeModVersion?
            return @_activeModVersion.findItem slug
        else
            for modVersion in @_modVersions
                modVersion.fetch()

                item = modVersion.findItem slug
                if item?
                    if options.enableAsNeeded then @setActiveVersion modVersion.version
                    return item

        return null

    findItemByName: (name)->
        return unless @_activeModVersion?
        @_activeModVersion.findItemByName name

    findName: (itemSlug)->
        return unless @_activeModVersion?
        @_activeModVersion.findName itemSlug

    findRecipes: (itemSlug, result=[], options={})->
        options.alwaysFromOwningMod ?= false

        if @_activeModVersion?
            return @_activeModVersion.findRecipes itemSlug, result, options
        else if options.alwaysFromOwningMod and itemSlug.mod is @slug
            return @getModVersion(Mod.Version.Latest).findRecipes itemSlug, result, options

        return null

    # Property Methods #############################################################################

    getActiveVersion: ->
        return @_activeVersion

    setActiveVersion: (version)->
        return if version is @_activeVersion

        version ?= Mod.Version.None
        if version is Mod.Version.Latest then version = _.last(@_modVersions).version

        if version is Mod.Version.None
            @_activeVersion = version
            @_activateModVersion null

            @trigger Event.change + ':activeVersion', this, @_activeVersion
            @trigger Event.change, this
        else
            for modVersion in @_modVersions
                if version is modVersion.version
                    @_activateModVersion modVersion
                    break

            @_activeVersion = version
            @trigger Event.change + ':activeVersion', this, @_activeVersion
            @trigger Event.change, this

    getActiveModVersion: ->
        return @_activeModVersion

    isEnabled: ->
        return @activeModVersion?

    addModVersion: (modVersion)->
        return unless modVersion?
        return if @_modVersions.indexOf(modVersion) isnt -1

        @_modVersions.push modVersion
        @listenTo modVersion, Event.change, => @trigger Event.change, this
        modVersion.mod = this

        @trigger Event.add + ':modVersion', modVersion, this
        @trigger Event.change + ':version', modVersion, this
        @trigger Event.change, this

        if not @activeVersion? then @activeVersion = modVersion.version
        if modVersion.version is @_activeVersion then @_activateModVersion modVersion
        return this

    eachModVersion: (callback)->
        for modVersion in @_modVersions
            callback modVersion

    getModVersion: (version)->
        return null if version is Mod.Version.None
        return @_modVersions[0] if version is Mod.Version.Latest

        for modVersion in @_modVersions
            return modVersion if modVersion.version is version

        return null

    addTutorial: (tutorial)->
        return unless tutorial?
        if @getTutorial(tutorial.slug)? then throw new Error "duplicate tutorial: #{tutorial.name}"
        @_tutorials.push tutorial
        tutorial.modSlug = @slug

    getAllTutorials: ->
        return @_tutorials[..]

    getTutorial: (tutorialSlug)->
        for tutorial in @_tutorials
            return tutorial if tutorial.slug is tutorialSlug
        return null

    Object.defineProperties @prototype,
        activeModVersion: { get:@prototype.getActiveModVersion }
        activeVersion:    { get:@prototype.getActiveVersion,   set:@prototype.setActiveVersion }
        enabled:          { get:@prototype.isEnabled }
        tutorials:        { get:@prototype.getAllTutorials }

    # Backbone.View Overrides ######################################################################

    parse: (text)->
        ModParser = require './mod_parser' # to avoid require cycles
        @_parser ?= new ModParser model:this
        @_parser.parse text

        return null # prevent calling `set`

    url: ->
        return Url.modData modSlug:@slug

    # Private Methods ##############################################################################

    _activateModVersion: (modVersion)->
        if @_activeModVersion? then @stopListening @_activeModVersion
        @_activeModVersion = modVersion
        @trigger Event.change + ':activeModVersion', this, @_activeModVersion

        logger.verbose => "#{@slug} switched to version #{@_activeVersion}"

        if @_activeModVersion?
            @listenTo @_activeModVersion, 'all', -> @trigger.apply this, arguments

    _verifyActiveModVersion: ->
        if (@_activeVersion isnt Version.None) and (not @_activeModVersion?)
            logger.warning => "#{@slug} no longer has a version #{@_activeVersion}, using latest instead"
            @activeVersion = Version.Latest
