###
Crafting Table - polyfill.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

########################################################################################################################

if not Array.prototype.clear?
    Object.defineProperty Array.prototype, 'clear', value:->
        @splice 0, @length
        return this
