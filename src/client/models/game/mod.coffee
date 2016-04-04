#
# Crafting Guide - mod.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

BaseModel = require '../base_model'

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

        @once c.event.sync, => @_verifyActiveModVersion()

    # Class Methods ##################################################################################

    @Version: Version =
        None: 'none'
        Latest: 'latest'

    # Public Methods #################################################################################

    compareTo: (that)->
        thisRequired = this.slug in c.requiredMods
        thatRequired = that.slug in c.requiredMods

        if thisRequired isnt thatRequired
            return -1 if thisRequired
            return +1 if thatRequired
        else if this.slug isnt that.slug
            return if this.slug < that.slug then -1 else +1

        return 0

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        activeModVersion:
            get: -> @_activeModVersion

        activeVersion:
            get: ->
                return @_activeVersion

            set: (version)->
                return if version is @_activeVersion

                version ?= Mod.Version.None
                if version is Mod.Version.Latest then version = _.last(@_modVersions).version

                if version is Mod.Version.None
                    @_activeVersion = version
                    @_activateModVersion null

                    @trigger c.event.change + ':activeVersion', this, @_activeVersion
                    @trigger c.event.change, this
                else
                    for modVersion in @_modVersions
                        if version is modVersion.version
                            @_activateModVersion modVersion
                            break

                    @_activeVersion = version
                    @trigger c.event.change + ':activeVersion', this, @_activeVersion
                    @trigger c.event.change, this

        enabled:
            get: -> @_activeModVersion?

        modVersions:
            get: -> @_modVersions[..]

        tutorials:
            get: -> @getAllTutorials()

    # Item Methods #################################################################################

    eachItem: (callback)->
        effectiveModVersion = @_activeModVersion or @getModVersion Mod.Version.Latest
        effectiveModVersion.eachItem callback

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

    # ModVersion Methods ###########################################################################

    addModVersion: (modVersion)->
        return unless modVersion?
        return if @_modVersions.indexOf(modVersion) isnt -1

        @_modVersions.push modVersion
        @listenTo modVersion, c.event.change, => @trigger c.event.change, this
        modVersion.mod = this

        @trigger c.event.add + ':modVersion', modVersion, this
        @trigger c.event.change + ':version', modVersion, this
        @trigger c.event.change, this

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

    # Name Methods #################################################################################

    eachName: (callback)->
        effectiveModVersion = @_activeModVersion or @getModVersion Mod.Version.Latest
        effectiveModVersion.eachName callback

    findName: (itemSlug)->
        return unless @_activeModVersion?
        @_activeModVersion.findName itemSlug

    # Recipe Methods ###############################################################################

    eachRecipe: (callback)->
        effectiveModVersion = @_activeModVersion or @getModVersion Mod.Version.Latest
        effectiveModVersion.eachRecipe callback

    findRecipes: (itemSlug, result=[], options={})->
        options.alwaysFromOwningMod ?= false

        if @_activeModVersion?
            return @_activeModVersion.findRecipes itemSlug, result, options
        else if options.alwaysFromOwningMod and itemSlug.mod is @slug
            return @getModVersion(Mod.Version.Latest).findRecipes itemSlug, result, options

        return null

    # Tutorial Methods #############################################################################

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

    # Backbone.Model Overrides #####################################################################

    parse: (text)->
        ModParser = require '../parsing/mod_parser' # to avoid require cycles
        @_parser ?= new ModParser model:this
        @_parser.parse text

        return null # prevent calling `set`

    url: ->
        return c.url.modData modSlug:@slug

    # Private Methods ##############################################################################

    _activateModVersion: (modVersion)->
        if @_activeModVersion? then @stopListening @_activeModVersion
        @_activeModVersion = modVersion
        @trigger c.event.change + ':activeModVersion', this, @_activeModVersion

        logger.verbose => "#{@slug} switched to version #{@_activeVersion}"

        if @_activeModVersion?
            @listenTo @_activeModVersion, 'all', -> @trigger.apply this, arguments

    _verifyActiveModVersion: ->
        if (@_activeVersion isnt Version.None) and (not @_activeModVersion?)
            logger.warning => "#{@slug} no longer has a version #{@_activeVersion}, using latest instead"
            @activeVersion = Version.Latest
