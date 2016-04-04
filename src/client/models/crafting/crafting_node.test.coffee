#
# Crafting Guide - crafting_node.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fixtures = require './fixtures.test'

########################################################################################################################

root = null

########################################################################################################################

describe 'crafting_node.coffee', ->

    describe 'acceptVisitor', ->

        it 'can provide a prefix, depth-first traversal', ->
            root = fixtures.makeTree 'test__iron_ingot'

            visitor =
                nodes: []
                onEnterOtherNode: (node)-> visitor.nodes.push node

            root.acceptVisitor visitor

            (v.constructor.name.replace('Node', '') for v in visitor.nodes).should.eql [
                "Inventory", "Item", "Recipe", "Item", "Item", "Recipe", "Item", "Item", "Recipe", "Item", "Item"
            ]

        it 'can provide a postfix, depth-first traversal', ->
            root = fixtures.makeTree 'test__iron_ingot'

            visitor =
                nodes: []
                onLeaveOtherNode: (node)-> visitor.nodes.push node

            root.acceptVisitor visitor

            (n.constructor.name.replace('Node', '') for n in visitor.nodes).should.eql [
                "Item", "Item", "Item", "Recipe", "Item", "Recipe", "Item", "Item", "Recipe", "Item", "Inventory"
            ]
