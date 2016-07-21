cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
OctobluRaven       = require 'octoblu-raven'
sendError          = require 'express-send-error'
bearerToken        = require 'express-bearer-token'
meshbluAuth        = require 'express-meshblu-auth'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
expressVersion     = require 'express-package-version'
debug              = require('debug')('friendly-sharefile-service:server')
Router             = require './router'

class Server
  constructor: ({@disableLogging,@port,@octobluRaven}, {@meshbluConfig,@jobManager})->
    @octobluRaven ?= new OctobluRaven()

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    ravenExpress = @octobluRaven.express()
    app.use sendError()
    app.use ravenExpress.meshbluAuthContext()
    app.use ravenExpress.handleErrors()
    app.use meshbluHealthcheck()
    app.use expressVersion {format: '{"version": "%s"}'}
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
