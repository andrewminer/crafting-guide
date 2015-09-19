###
Crafting Guide - crafting_node.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_ = require 'underscore'

########################################################################################################################

module.exports = class CraftingNode

    @::TYPES =
        INVENTORY: 0
        ITEM: 1
        RECIPE: 2

    @::TYPE = null

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'

        @modPack = options.modPack

        @_children  = []
        @_complete  = null
        @_id        = _.uniqueId 'node_'
        @_rotations = 0
        @_valid     = null

    # Public Methods ###############################################################################

    expand: (queue=[])->
        return queue if @children.length > 0

        for child in @_createChildren()
            child.parent = this
            if child.valid
                @_children.push child
                queue.push child
        return queue

    acceptVisitor: (visitor)->
        enter = visitor[@ENTER_METHOD]
        if enter?
            enter.call visitor, this
        else
            enter = visitor['onEnterOtherNode']
            if enter? then enter.call visitor, this

        for child in @_children
            child.acceptVisitor visitor

        leave = visitor[@LEAVE_METHOD]
        if leave?
            leave.call visitor, this
        else
            leave = visitor['onLeaveOtherNode']
            if leave? then leave.call visitor, this

    rotateChildren: ->
        @_children.push @_children.shift()
        @_rotations += 1

    # Property Methods #############################################################################

    getChildren: ->
        return @_children

    isComplete: ->
        if not @_complete?
            @_complete = @_checkCompleteness()
        return @_complete

    getCompleteText: ->
        return if @complete then "✓" else "✗"

    getDepth: ->
        maxDepth = 1
        for child in @children
            maxDepth = Math.max maxDepth, child.getDepth() + 1
        return maxDepth

    getId: ->
        return @_id

    getRotations: ->
        return @_rotations

    getSize: ->
        size = 1
        for child in @children
            size += child.size
        return size

    isValid: ->
        return @_valid if @_valid?

        valid = @_checkValidity()
        @_valid = false if not valid

        return valid

    Object.defineProperties @prototype,
        children:     { get:@prototype.getChildren     }
        complete:     { get:@prototype.isComplete      }
        completeText: { get:@prototype.getCompleteText }
        depth:        { get:@prototype.getDepth        }
        id:           { get:@prototype.getId           }
        rotations:    { get:@prototype.getRotations    }
        size:         { get:@prototype.getSize         }
        valid:        { get:@prototype.isValid         }

    # Virtual Methods ##############################################################################

    # Subclasses must override this method to create such children as are appropriate for that kind of node. The new
    # nodes should be appended to the given array.
    _createChildren: (result)->
        throw new Error "#{@constructor.name} must override the _createChildren method"

    # Subclasses must override this method to indicate whether the node has at least one "complete" subtree rooted with
    # itself. Completeness may be defined differently by different subclasses.
    _checkCompleteness: ->
        throw new Error "#{@constructor.name} must override the _checkCompletness method"

    # Subclasses must override this method to determine whether the subtree represented by a node should still be
    # explored for having a useful crafting plan.
    _checkValidity: ->
        throw new Error "#{@constructor.name} must override the _checkValidity method"
