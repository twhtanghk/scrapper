puppeteer = require 'puppeteer'

browser = ->
  opts =
    args: [
      '--no-sandbox'
      '--disable-setuid-sandbox'
      '--disable-dev-shm-usage'
    ]
    handleSIGTERM: false
  if process.env.DEBUG? and process.env.DEBUG == 'true'
    opts = Object.assign opts,
      headless: false
      devtools: true
  await puppeteer.launch opts

class Scrapper
  constructor: (browser, @url) ->
    @browser = browser
    return do =>
      @page = await browser.newPage()
      await @page.setRequestInterception true
      @page.on 'request', (req) =>
        allowed = new URL @url
        curr = new URL req.url()
        if req.resourceType() == 'image' or curr.hostname != allowed.hostname
          req.abort()
        else
          req.continue()
      await @page.goto @url, waitUntil: 'networkidle2'
      @

  text: (el) ->
    content = (el) ->
      el.textContent
    (await @page.evaluate content, el).trim()

class CCASS extends Scrapper
  constructor: (browser, code) ->
    return do =>
      ret = await super browser, 'https://www.hkexnews.hk/sdw/search/searchsdw_c.aspx'
      ret.code = code
      ret

  totalShare: ->
    try
      await @page.$eval '#txtStockCode', ((el, code) =>
        el.value = code), @code
      await @page.click '#btnSearch'
      await @page.waitForNavigation waitUntil: 'networkidle2'
      parseInt (await @text await @page.$ '.summary-value').replace /,/g, ''
    finally
      await @page.close()

module.exports =
  browser: browser
  Scrapper: Scrapper
  CCASS: CCASS
