###
# Crafting Guide - Gruntfile.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

fs   = require 'fs'
util = require 'util'

########################################################################################################################

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init
        browserify:
            main:
                options:
                    ignore: ['http', 'jade', 'underscore', 'when']
                files:
                    './dist/js/main.js': ['./build/main.js']

            markdown:
                options:
                    browserifyOptions:
                        debug: false
                        standalone: 'markdown'
                files:
                    './dist/js/markdown.js': ['./node_modules/markdown/lib/index.js']

            when:
                options:
                    browserifyOptions:
                        debug: false
                        standalone: 'w'
                files:
                    './dist/js/when.js': ['./node_modules/when/when.js']

        clean:
            build: ['./build']
            dist: ['./dist']

        coffee:
            files:
                expand: true
                cwd:    './src/coffee'
                src:    '**/*.coffee'
                dest:   './build'
                ext:    '.js'
                extDot: 'last'

        copy:
            scripts:
                files:
                    './dist/js/backbone.js':   ['./node_modules/backbone/backbone.js']
                    './dist/js/chai.js':       ['./node_modules/chai/chai.js']
                    './dist/js/jade.js':       ['./node_modules/jade/runtime.js']
                    './dist/js/jquery.js':     ['./node_modules/jquery/dist/jquery.js']
                    './dist/js/mocha.js':      ['./node_modules/mocha/mocha.js']
                    './dist/js/underscore.js': ['./node_modules/underscore/underscore.js']
            styles:
                files: [expand:true, cwd:'./src/css', src:'**/*.scss', dest:'./dist/src/css']
            style_extras:
                files:
                    './dist/css/mocha.css': ['./node_modules/mocha/mocha.css']
            views:
                files:
                    './build/views.js': ['./src/coffee/views.js']

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
                tasks: ['coffee', 'browserify:main']
            jade:
                files: ['./src/**/*.jade']
                tasks: ['jade:pages', 'jade:templates', 'copy:views', 'browserify:main']
            sass:
                files: ['./src/**/*.scss']
                tasks: ['sass', 'copy:styles']

    grunt.registerTask 'default', 'build'

    grunt.registerTask 'build', [ 'rsync', 'sass:build', 'jade', 'coffee', 'copy', 'browserify' ]

    grunt.registerTask 'dist', ['test', 'clean', 'build', 'sass:dist', 'uglify']

    grunt.registerTask 'clean-watch', ['clean', 'build', 'watch']

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
