###
Crafting Guide - email_client.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

require 'underscore'

########################################################################################################################

module.exports = class EmailClient

    constructor: ->
        @baseUrl = 'https://mandrillapp.com:443/api/1.0'
        @key     = 'zaERWIuTVJaq0seCjjgVqw'

    # Public Methods ###############################################################################

    send: (options={})->
        options.body        ?= "(no body)"
        options.fromAddress ?= "wesbite@redwood-labs.com"
        options.fromName    ?= "Crafting Guide Website"
        options.subject     ?= "(no subject)"
        options.toAddress   ?= "crafting-guide@redwood-labs.com"
        options.toName      ?= "Crafting Guide"

        body =
            key:            @key
            message:
                from_email: options.fromAddress
                from_name:  options.fromName
                subject:    options.subject
                text:       options.body
                to:         [ email:options.toAddress, name:options.toName, type:'to' ]

        logger.info -> "sending email: #{util.inspect(body)}"

        w.promise (resolve, reject)=>

            onSuccess = (data, status, request)->
                logger.info -> "sending email result: #{util.inspect(data)}, status:#{status}"
                data = if _.isArray data then data[0] else data
                if data.status isnt "sent"
                    reject status:data.status, message:data.reject_reason
                else
                    resolve status:data.status

            onError = (request, status, error)->
                logger.error -> "sending email failed: #{status}, error:#{error}"
                reject status:status, message:error

            $.ajax "#{@baseUrl}/messages/send.json",
                cache:    false
                data:     body
                dataType: 'json'
                error:    onError
                success:  onSuccess
                type:     'POST'
