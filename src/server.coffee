cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
OctobluRaven       = require 'octoblu-raven'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
meshbluAuth        = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
bearerToken        = require 'express-bearer-token'
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
    app.use ravenExpress.requestHandler()
    app.use ravenExpress.errorHandler()
    app.use ravenExpress.sendError()
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
