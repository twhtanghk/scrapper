require('config')().bootstrap()
  .then (config) ->
    global.config = config

module.exports =
  require 'http'
    .createServer()
    .listen port: process.env.PORT || 3000
