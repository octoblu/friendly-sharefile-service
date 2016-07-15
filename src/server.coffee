cors               = require 'cors'
raven              = require 'raven'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
meshbluAuth        = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
bearerToken        = require 'express-bearer-token'
debug              = require('debug')('friendly-sharefile-service:server')
Router             = require './router'

class Server
  constructor: ({@disableLogging, @port,@sentryDSN}, {@meshbluConfig,@jobManager})->

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use raven.middleware.express.requestHandler @sentryDSN if @sentryDSN
    app.use raven.middleware.express.errorHandler @sentryDSN if @sentryDSN
    app.use meshbluHealthcheck()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use bodyParser.urlencoded limit: '50mb', extended : true
    app.use bodyParser.json limit : '50mb'
    app.use bearerToken()

    app.options '*', cors()

    router = new Router {@meshbluConfig,@jobManager}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
