cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
meshbluAuth        = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
bearerToken        = require 'express-bearer-token'
debug              = require('debug')('sharefile-service:server')
Router             = require './router'

class Server
  constructor: ({@disableLogging, @port})->

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use meshbluHealthcheck()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'
    app.use bearerToken()

    app.use (request, response, next) =>
      sharefileDomain = request.header 'X-SHAREFILE-DOMAIN'
      return response.status(422).send error: 'Missing X-SHAREFILE-DOMAIN header' unless sharefileDomain?
      request.sharefileDomain = sharefileDomain
      next()

    app.options '*', cors()

    router = new Router {@sharefileUri}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
