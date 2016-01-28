cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
meshbluAuth        = require 'express-meshblu-auth'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
MeshbluConfig      = require 'meshblu-config'
bearerToken        = require 'express-bearer-token'
debug              = require('debug')('sharefile-service:server')
Router             = require './router'
SharefileService   = require './services/sharefile-service'

class Server
  constructor: (options)->
    {@meshbluConfig} = options
    {@disableLogging, @port} = options
    {@sharefileUri} = options

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
    app.use (request, response) ->
      response.send "Token #{request.token}" 

    app.options '*', cors()

    sharefileService = new SharefileService {@meshbluConfig, @sharefileUri}
    router = new Router {@meshbluConfig, sharefileService}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
