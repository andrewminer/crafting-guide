#
# Crafting Guide - Gruntfile.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fs = require 'fs'

EXTERNAL_LIBS = [
    'backbone'
    'jquery'
    'marked'
    'underscore'
    'underscore.inflections'
    'when'
    './vendor/email.js:emailjs'
]

PUBLISHED_FILES = [
    './client/models/base_model.coffee'
    './client/models/game/inventory.coffee'
    './client/models/game/item.coffee'
    './client/models/game/item_slug.coffee'
    './client/models/game/mod.coffee'
    './client/models/game/mod_version.coffee'
    './client/models/game/multiblock.coffee'
    './client/models/game/recipe.coffee'
    './client/models/game/stack.coffee'
    './client/models/game/simple_stack.coffee'
    './client/models/parsing/command_parser_version_base.coffee'
    './client/models/parsing/mod_parser.coffee'
    './client/models/parsing/mod_parser_v1.coffee'
    './client/models/parsing/mod_version_parser.coffee'
    './client/models/parsing/mod_version_parser_v1.coffee'
    './client/models/parsing/versioned_parser_base.coffee'
    './client/models/site/tutorial.coffee'
    './common/constants.coffee'
    './common/underscore.coffee'
    './index.coffee'
]

########################################################################################################################

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init

        compress:
            static:
                options:
                    mode: 'gzip'
                files: [
                    {expand: true, cwd:'./build/static', src:'**/*.css',     dest:'./dist/'}
                    {expand: true, cwd:'./build/static', src:'**/*.html',    dest:'./dist/'}
                    {expand: true, cwd:'./build/static', src:'**/*.ugly.js', dest:'./dist/', ext: '.js'}
                    {expand: true, cwd:'./build/static', src:'**/*.json',    dest:'./dist/'}
                    {expand: true, cwd:'./build/static', src:'**/*.ttf',     dest:'./dist/'}
                    {expand: true, cwd:'./build/static', src:'**/*.txt',     dest:'./dist/'}
                ]

        coffee:
            npm_package:
                options: {
                    bare: true
                }
                files: [
                    {expand:true, cwd:'./src', src:PUBLISHED_FILES, dest:'./dist', ext:'.js'}
                ]

        copy:
            assets_build:
                files: [
                    {expand:true, cwd:'./assets/', src:'**/*', dest:'./build/static'}
                ]
            build_to_dist:
                files: [
                    {expand:true, cwd:'./build/static/', src:['**/*', '!**/*.map', '!**/*.js'], dest:'./dist'}
                ]
            common_source:
                files: [
                    {expand:true, cwd:'./src/common', src:'**/*.coffee', dest:'./build', ext:'.coffee'}
                ]
            server_source:
                files: [
                    {expand:true, cwd:'./src/server', src:'**/*.coffee', dest:'./build', ext:'.coffee'}
                ]

        clean:
            assets:    ['./build/static/data', './build/static/images']
            build:     ['./build']
            dist:      ['./dist']
            templates: ['./src/client/site/templates.js']

        jade:
            pages:
                options:
                    pretty: true
                files: [
                    expand: true
                    cwd:  './src/client/site'
                    src:  '**/index.jade'
                    dest: './build/static'
                    ext:  '.html'
                ]
            templates:
                options:
                    client: true
                    node: true
                    processName: (path)->
                        pathElements = path.split '\/'
                        while true
                            element = pathElements.shift()
                            break if element is 'site'
                        pathElements.pop()
                        name = pathElements.join '/'
                        name = name.replace '.jade', ''
                        return name
                files:
                    './src/client/site/templates.js': ['./src/client/site/**/!(index)*.jade']

        mochaTest:
            options:
                bail:     true
                color:    true
                reporter: 'dot'
                require: [
                    'coffee-script/register'
                    './src/test_helper.coffee'
                ]
                verbose: true
            src: ['./src/**/*.test.coffee']

        sass:
            all:
                files:
                    './build/static/main.css': [ './build/imports.scss' ]

        sass_globbing:
            all:
                files:
                    './build/imports.scss': [
                        './src/client/styles/main.scss'
                        './src/client/site/**/*.scss'
                    ]

        uglify:
            scripts:
                options:
                    maxLineLen: 20
                files: [
                    expand: true
                    cwd:  './build/static'
                    src:  '**/*.js'
                    dest: './build/static'
                    ext:  '.ugly.js'
                ]

        watch:
            assets:
                files: ['./assets/**/*']
                tasks: ['copy:assets_build']
            client_source:
                files: ['./src/{client,common}/**/*.coffee']
                tasks: ['browserify:internal']
            server_source:
                files: ['./src/{common,server}/**/*.coffee']
                tasks: ['copy:server_source']
            jade_pages:
                files: ['./src/**/index.jade']
                tasks: ['jade:pages']
            jade_templates:
                files: ['./src/**/!(index).jade']
                tasks: ['jade:templates', 'browserify:internal']
            sass:
                files: ['./src/**/*.scss']
                tasks: ['sass']
            test:
                files: ['./src/**/*.coffee', './src/**/*.js', './test/**/*.coffee']
                tasks: ['script:clear', 'test']

    # Compound Tasks ###################################################################################################

    grunt.registerTask 'build', 'build the project to be run from a local server',
        ['jade', 'build:copy', 'build:css', 'browserify:external', 'browserify:internal']

    grunt.registerTask 'build:copy', 'helper task for build',
        ['copy:assets_build', 'copy:common_source', 'copy:server_source']

    grunt.registerTask 'build:css', 'helper task for build',
        ['sass_globbing', 'sass']

    grunt.registerTask 'default', 'rebuild the project from scratch and start a local HTTP server',
        ['clean', 'start']

    grunt.registerTask 'deploy', 'deploy to both staging and production via CircleCI',
        ['deploy:staging', 'deploy:prod']

    grunt.registerTask 'deploy:prod', 'deploy the project to production via CircleCI',
        ['script:deploy:prod']

    grunt.registerTask 'deploy:staging', 'deploy the project to staging via CircleCI',
        ['script:deploy:staging']

    grunt.registerTask 'dist', 'build the project to be run from Amazon S3',
        ['build', 'copy:build_to_dist', 'uglify', 'compress']

    grunt.registerTask 'prepublish', 'build the project to be published to NPM as shared code',
        ['clean', 'coffee']

    grunt.registerTask 'publish', 'publish the project to NPM',
        ['prepublish', 'script:publish', 'clean', 'build']

    grunt.registerTask 'start', 'build the project and start a local HTTP server',
        ['build', 'script:start']

    grunt.registerTask 'test', 'run unit tests',
        ['mochaTest']

    grunt.registerTask 'upload:prod', 'upload the project to the production Amazon S3 environment',
        ['dist', 'script:s3_upload:prod']

    grunt.registerTask 'upload:staging', 'upload the project the staging Amazon S3 environment',
        ['dist', 'script:s3_upload:staging']

    grunt.registerTask 'useLocalDeps', 'use local dependencies instead of NPM dependencies',
        ['script:use_local_deps']

    # Code Tasks #######################################################################################################

    grunt.registerTask 'browserify:external', "Bundle 3rd-party libraries used in the app", ->
        grunt.file.mkdir './build/static'
        done = this.async()

        args = [].concat ("--require=#{lib}" for lib in EXTERNAL_LIBS), [
            '--outfile=./build/static/external.js'
        ]

        options = cmd:'browserify', args:args
        grunt.util.spawn options, (error)->
            console.log error if error?
            done()

    grunt.registerTask 'browserify:internal', "Bundle source files needed in the browser", ->
        grunt.file.mkdir './build/static'
        done = this.async()

        libs = []
        for lib in EXTERNAL_LIBS
            parts = lib.split ':'
            libs.push parts[parts.length-1]

        args = [].concat ("--external=#{lib}" for lib in libs), [
            '--extension=.coffee'
            '--outfile=./build/static/internal.js'
            '--transform=coffeeify'
            './src/client/client.coffee'
        ]

        options = cmd:'browserify', args:args
        grunt.util.spawn options, (error)->
            console.log error if error?
            done()

    # Script Tasks #####################################################################################################

    grunt.registerTask 'script:clear', "clear the current terminal buffer", ->
      done = this.async()
      grunt.util.spawn cmd:'clear', opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:deploy:prod', "deploy code by copying to the production branch", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/deploy', args:['--prod'], opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:deploy:staging', "deploy code by copying to the staging branch", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/deploy', args:['--staging'], opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:publish', 'publishes this package to NPM', ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/publish', opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:s3_upload:prod', 'uploads all static content to S3', ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/s3_upload', args:['--prod'], opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:s3_upload:staging', 'uploads all static content to S3', ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/s3_upload', args:['--staging'], opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:start', "start a local HTTP server on port 8080", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/start', opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:use_local_deps', "use local dependencies instead of NPM dependencies", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/use_local_deps', opts:{stdio:'inherit'}, (error)-> done(error)

    # Command-Line Argument Processing #################################################################################

    args = process.argv[..]
    while args.length > 0
        switch args[0]
            when '--grep'
                args.shift()
                grunt.config.merge mochaTest:options:grep:args[0]

        args.shift()
