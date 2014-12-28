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
                    './dist/js/main.js': ['./src/scripts/main.coffee']
            test:
                options:
                    transform: ['coffeeify']
                    browserifyOptions:
                        debug: true
                        extensions: ['.coffee']
                files:
                    './dist/js/test.js': ['./test/test.coffee']
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
            data:
                files: [expand:true, cwd:'./src/data', src:'**/*.json', dest:'./dist/data']
            fonts:
                files: [expand:true, cwd:'./src/fonts', src:'**/*.ttf', dest:'./dist/fonts']
            images:
                files: [expand:true, cwd:'./src/images/', src:['**/*.png', '**/*.jpg'], dest:'./dist/images']
            jquery_ui_images:
                files: [expand:true, cwd:'./lib/jquery-ui/images', src:['*.png'], dest:'./dist/css/images']
            scripts:
                files:
                    './dist/js/backbone.js': ['./node_modules/backbone/backbone.js']
                    './dist/js/chai.js': ['./node_modules/chai/chai.js']
                    './dist/js/jade.js': ['./node_modules/jade/runtime.js']
                    './dist/js/jquery.js': ['./node_modules/jquery/dist/jquery.js']
                    './dist/js/jquery-ui.js': ['./lib/jquery-ui/jquery-ui.js']
                    './dist/js/mocha.js': ['./node_modules/mocha/mocha.js']
                    './dist/js/underscore.js': ['./node_modules/backbone/node_modules/underscore/underscore.js']
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
                    cwd: './src/pages'
                    src: '*.jade'
                    dest: './dist'
                    ext: '.html'
                ]

            templates:
                options:
                    client: true
                    node: true
                    pretty: true
                    processName: (f)->
                        f = f.replace './src/templates/', ''
                        f = f.replace '_view', ''
                        f = f.replace '.jade', ''
                        f = f.replace /\//g, '_'
                        return f
                files:
                    './src/scripts/views.js': ['./src/templates/**/*.jade']

        sass:
            main:
                files:
                    './dist/css/main.css': ['./src/css/main.scss']

        watch:
            fonts:
                files: ['./src/fonts/**/*']
                tasks: ['copy:fonts']
            images:
                files: ['./src/images/**/*']
                tasks: ['copy:images']
            source:
                files: ['./src/scripts/**/*.coffee']
                tasks: ['browserify:main']
            pages:
                files: ['./src/pages/**/*.jade']
                tasks: ['jade:pages']
            templates:
                files: ['./src/templates/**/*.jade']
                tasks: ['jade:templates', 'browserify:main']
            sass:
                files: ['./src/css/**/*.scss']
                tasks: ['sass', 'copy:styles']
            tests:
                files: ['./src/scripts/**/*.coffee', './test/**/*.coffee']
                tasks: ['browserify:test']

    grunt.registerTask 'default', 'build'

    grunt.registerTask 'build', ['copy', 'sass', 'jade', 'browserify', 'exorcise']
