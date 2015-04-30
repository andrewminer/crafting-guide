###
# Crafting Guide - Gruntfile.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

fs   = require 'fs'
util = require 'util'

########################################################################################################################

LIBRARY_ALIAS_MAPPING = [
    './node_modules/jquery/dist/jquery.js:jquery'
    './node_modules/backbone/backbone.js:backbone'
    './node_modules/jade/runtime.js:jade'
    './node_modules/markdown/lib/index.js:markdown'
    './node_modules/underscore/underscore.js:underscore'
    './node_modules/when/when.js:when'
]

LIBRARIES = (s.substring(0, s.indexOf(':')) for s in LIBRARY_ALIAS_MAPPING)
ALIASES = (s.substring(s.indexOf(':') + 1) for s in LIBRARY_ALIAS_MAPPING)

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init
        browserify:
            dev:
                options:
                    browserifyOptions:
                        debug: true
                        extensions: ['.coffee']
                    transform: ['coffeeify']
                files: './dist/js/main.js': ['./src/coffee/main.coffee']
            prod:
                files: './dist/js/main.js': ['./src/coffee/main.coffee']

        coffee:
            dev:
                options:
                    sourceMap: true
                files: [expand:true, cwd:'./src/coffee', src:'**/*.coffee', dest:'./dist']

        clean:
            dist: ['./dist']

        copy:
            styles:
                files: [expand:true, cwd:'./src/css', src:'**/*.scss', dest:'./dist/src/css']
            style_extras:
                files:
                    './dist/css/mocha.css': ['./node_modules/mocha/mocha.css']

        exorcise:
            dev:
                files: './dist/js/main.js.map': ['./dist/js/main.js']

        jade:
            pages:
                options:
                    pretty: true
                files: [
                    expand: true
                    cwd: './src/jade'
                    src: '*.jade'
                    dest: './dist'
                    ext: '.html'
                ]

            templates:
                options:
                    client: true
                    node: true
                    processName: (f)->
                        f = f.replace './src/jade/templates/', ''
                        f = f.replace '_view', ''
                        f = f.replace '.jade', ''
                        f = f.replace /\//g, '_'
                        return f
                files:
                    './src/coffee/views.js': ['./src/jade/templates/**/*.jade']

        mochaTest:
            options:
                bail:     true
                color:    true
                reporter: 'dot'
                require: [
                    'coffee-script/register'
                    './test/test_helper.coffee'
                ]
                verbose: true
            src: ['./test/**/*.test.coffee']

        rsync:
            static:
                options:
                    src: './static/'
                    dest: './dist/'
                    recursive: true

        sass:
            build:
                files:
                    './dist/css/main.css': ['./src/scss/main.scss']
            dist:
                options:
                    sourcemap: 'none'
                    style: 'compressed'
                files:
                    './dist/css/main.css': ['./src/scss/main.scss']

        uglify:
            scripts:
                options:
                    maxLineLen: 20
                files: [
                    expand: true
                    cwd: './dist/js'
                    src: '**/*.js'
                    dest: './dist/js'
                ]

        watch:
            static:
                files: ['./static/**/*']
                tasks: ['rsync:static']
            coffee:
                files: ['./src/**/*.coffee']
                tasks: ['browserify:dev', 'exorcise']
            jade:
                files: ['./src/**/*.jade']
                tasks: ['jade:pages', 'jade:templates', 'copy:views', 'browserify:dev', 'exorcise']
            sass:
                files: ['./src/**/*.scss']
                tasks: ['sass', 'copy:styles']

    grunt.registerTask 'default', 'build'

    grunt.registerTask 'build', ['rsync', 'sass:build', 'jade', 'copy', 'browserify:dev', 'exorcise']

    grunt.registerTask 'clean-watch', ['clean', 'build', 'watch']

    grunt.registerTask 'dist', ['rsync', 'sass:dist', 'jade', 'copy', 'browserify:prod', 'uglify']

    grunt.registerTask 'prepublish', ['clean', 'coffee']

    grunt.registerTask 'use-local-deps', ->
        grunt.file.mkdir './node_modules'
        grunt.file.delete './node_modules/crafting-guide-common', force:true
        fs.symlinkSync '../../crafting-guide-common/', './node_modules/crafting-guide-common'

    grunt.registerTask 'test', ['mochaTest']

    args = process.argv[..]
    while args.length > 0
        switch args[0]
            when '--grep'
                args.shift()
                grunt.config.merge mochaTest:options:grep:args[0]

        args.shift()
