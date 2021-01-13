{browser, CCASS} = require '../index'

describe 'totalShare', ->
  it '9988', ->
    try
      browser = await browser()
      console.log await (await new CCASS browser, '9988').totalShare()
    finally
      await browser.close()
