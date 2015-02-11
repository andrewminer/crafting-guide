###
Crafting Guide - underscore.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

_.mixin

    slugify: (text)->
        return null unless text?

        result = text.toLowerCase()
        result = result.replace /[^a-zA-Z0-9_]/g, '_'
        result = result.replace /__+/, '_'
        result = result.replace /^_/, ''
        result = result.replace /_$/, ''
        return result

    composeSlugs: (part1, part2)->
        return "#{part1}__#{part2}"

    decomposeSlug: (slug)->
        return [null, null] unless slug?

        parts = slug.split '__'
        if parts.length is 1
            parts = [ null, parts[0] ]

        return parts
