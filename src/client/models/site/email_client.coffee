#
# Crafting Guide - email_client.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

emailjs = require 'emailjs'

########################################################################################################################

emailjs.init 'user_sLxEH6RwPvzowjaIkfY6H'

########################################################################################################################

module.exports = class EmailClient

    constructor: ->
        @serviceId = 'default_service'

    # Public Methods ###############################################################################

    send: (template, data={})->
        logger.info -> "sending email with template #{template} and data: #{JSON.stringify(data)}"

        emailjs.send @serviceId, template, data
            .then (response)->
                logger.info -> "Email sent! status: #{response.status}, message: #{response.text}"
                return status:response.status, message:response.text
            .catch (error)->
                logger.error -> "Email failed! error: #{error}"
                throw error
