###
# Crafting Guide - Gruntfile.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

########################################################################################################################

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init
        browserify:
            main:
                options:
                    ignore: ['jade']
                    transform: ['coffeeify']
                    browserifyOptions:
                        debug: true
                        extensions: ['.coffee']
                files:
                    './dist/js/main.js': ['./src/coffee/main.coffee']
            test:
                options:
                    transform: ['coffeeify']
                    browserifyOptions:
                        debug: true
                        extensions: ['.coffee']
                files:
                    './dist/js/test.js': ['./src/coffee/test/test.coffee']
            when:
                options:
                    browserifyOptions:
                        debug: false
                        standalone: 'w'
                files:
                    './dist/js/when.js': ['./node_modules/when/when.js']

        clean:
            dist: ['./dist']

        copy:
            index_prerender:
                files:
                    './dist/index.html': ['./static/index.html']
            jquery_ui_images:
                files: [expand:true, cwd:'./lib/jquery-ui/images', src:['*.png'], dest:'./dist/css/images']
            scripts:
                files:
                    './dist/js/backbone.js':   ['./node_modules/backbone/backbone.js']
                    './dist/js/chai.js':       ['./node_modules/chai/chai.js']
                    './dist/js/jade.js':       ['./node_modules/jade/runtime.js']
                    './dist/js/jquery.js':     ['./node_modules/jquery/dist/jquery.js']
                    './dist/js/jquery-ui.js':  ['./lib/jquery-ui/jquery-ui.js']
                    './dist/js/mocha.js':      ['./node_modules/mocha/mocha.js']
                    './dist/js/underscore.js': ['./node_modules/underscore/underscore.js']
            styles:
                files: [expand:true, cwd:'./src/css', src:'**/*.scss', dest:'./dist/src/css']
            style_extras:
                files:
                    './dist/css/jquery-ui.css': ['./lib/jquery-ui/jquery-ui.min.css']
                    './dist/css/mocha.css': ['./node_modules/mocha/mocha.css']

        exorcise:
            main:
                files:
                    './dist/js/main.js.map': ['./dist/js/main.js']
            test:
                files:
                    './dist/js/test.js.map': ['./dist/js/test.js']

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
                tasks: ['browserify:main']
            jade:
                files: ['./src/**/*.jade']
                tasks: ['jade:pages', 'jade:templates']
            sass:
                files: ['./src/**/*.scss']
                tasks: ['sass', 'copy:styles']
            tests:
                files: ['./src/**/*.coffee', './test/**/*.coffee']
                tasks: ['browserify:test']

    grunt.registerTask 'default', 'build'

    grunt.registerTask 'build', [ 'rsync', 'copy', 'sass:build', 'jade', 'browserify', 'exorcise' ]

    grunt.registerTask 'dist', ['clean', 'build', 'copy:index_prerender', 'sass:dist', 'uglify']

    grunt.registerTask 'clean-watch', ['clean', 'build', 'watch']
