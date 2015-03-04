#!/usr/bin/env phantomjs --web-security=false

fs      = require 'fs'
system  = require 'system'
webPage = require 'webpage'

if system.args.length isnt 2
    console.error 'USAGE: prerender <path>'
    phantom.exit 1

########################################################################################################################

urlsFileName      = system.args[1]
urls              = fs.read(urlsFileName).split('\n')
outputDir         = 'prerender'
currentPage       = null
currentOutputPath = null
renderTime        = 5000

urls = (url.trim() for url in urls when url.trim().length > 0)

if not fs.exists outputDir
    fs.makeDirectory outputDir

startNextPage = ->
    url = urls.pop()
    if !url then phantom.exit()

    path              = "#{url}".replace(/http:\/\/[^/]*/, '').replace(/^\//, '')
    url               = "http://localhost:8000/#{path}"
    currentOutputPath = "#{outputDir}/#{path}"
    currentOutputPath = "#{outputDir}/index.html" if currentOutputPath is ''

    if not fs.exists currentOutputPath
        currentPage = webPage.create()
        console.log "Opening #{url}..."
        currentPage.open url, completePage()
    else
        setTimeout startNextPage, 0

completePage = (status)->
    if status is 'fail'
        console.error "Could not load #{url}"
        startNextPage()

    setTimeout (->
        fs.write currentOutputPath, currentPage.content, 'w'
        startNextPage()
    ), renderTime

startNextPage()
