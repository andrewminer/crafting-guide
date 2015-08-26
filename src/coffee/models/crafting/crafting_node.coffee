###
Crafting Guide - crafting_node.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

module.exports = class CraftingNode

    constructor: (options={})->
        if not options.modPack? then throw new Error 'options.modPack is required'

        @modPack = options.modPack

        @_children = []
        @_complete = null
        @_valid    = null

    # Public Methods ###############################################################################

    expand: (queue=[])->
        return queue if @children.length > 0

        for child in @_createChildren()
            child.parent = this
            @_children.push child
            queue.push child
        return queue

    getNode: (path)->
        return null unless _.isArray(path) and path.length > 0

        child = @children[path[0]]
        return null unless child?

        return child.getPath path[1..]

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

    getSize: ->
        size = 1
        for child in @children
            size += child.size
        return size

    getNodeType: ->
        return @_nodeType

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
        size:         { get:@prototype.getSize         }


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
