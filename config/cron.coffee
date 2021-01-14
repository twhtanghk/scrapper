CCASS = require '../index'

module.exports =
  cron: [
    {
      at: "0 0 23 * * 1-5"
      task: ->
        {browser, stock, mqtt} = global.config
        for code, totalShare of stock
          try
            stock[code] = await (await new CCASS browser, code).totalShare()
            mqtt.client.publish 'stock/hkex', JSON.stringify
              src: 'hkex'
              symbol: code
              totalShare: stock[code]
          catch err
            console.error "error to get totalShare of #{code}"
    }
  ]
