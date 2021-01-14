scheduler = require 'node-schedule'
{browser} = require '../index'

module.exports =
  bootstrap: ->
    @browser = await browser()
    @cron.map ({at, task}) ->
        scheduler.scheduleJob at, ->
          try
            task()
          catch err
            console.error err
    @
