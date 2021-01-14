{connect} = require 'mqtt'
{browser, CCASS} = require '../index'

module.exports =
  mqtt:
    client:
      connect process.env.MQTTURL,
        username: process.env.MQTTUSER
        clientId: 'scrapper'
        clean: false
      .on 'connect', ->
        @subscribe 'stock/#', qos: 2
      .on 'error', console.error
      .on 'message', (topic, msg) ->
        {action, data} = JSON.parse msg.toString()
        {browser, stock} = global.config
        if topic == 'stock'
          switch action
            when 'subscribe'
              for code in data
                try
                  if code not of stock
                    stock[code] = await (await new CCASS browser, code).totalShare()
                  @publish 'stock/hkex', JSON.stringify
                    src: 'hkex'
                    symbol: code
                    totalShare: stock[code]
                catch err
                  console.error err
                  console.error "error to get totalShare of #{code}"
            when 'unsubscribe'
              data.map (code) ->
                delete stock[code]
      
