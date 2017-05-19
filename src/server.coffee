octobluExpress     = require 'express-octoblu'
bearerToken        = require 'express-bearer-token'
Router             = require './router'

class Server
  constructor: ({@disableLogging,@port}, {@meshbluConfig,@jobManager})->

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress()
    app.use bearerToken()

    router = new Router {@meshbluConfig,@jobManager}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
