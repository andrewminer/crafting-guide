###
Crafting Guide - underscore_mixins.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

_.mixin

    parseMarkdown: (text)->
        return markdown.parse text, 'Maruku'

    slugify: (text)->
        return null unless text?

        result = text.toLowerCase()
        result = result.replace /[^a-zA-Z0-9_]/g, '_'
        result = result.replace /__+/g, '_'
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

_.mixin require('crafting-guide-common').stringMixins
