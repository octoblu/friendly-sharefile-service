_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
Server        = require './src/server'

class Command
  constructor: ->
    @serverOptions =
      meshbluConfig        : new MeshbluConfig().toJSON()
      port                 : process.env.PORT || 80
      disableLogging       : process.env.DISABLE_LOGGING == "true"
      sharefileUri         : process.env.SHAREFILE_URI || 'https://octoblu.sf-api.com/sf/v3'

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    @panic new Error('Missing required environment variable: MESHBLU_CONFIG') if _.isEmpty @serverOptions.meshbluConfig
    @panic new Error('Missing required environment variable: SHAREFILE_URI') if _.isEmpty @serverOptions.sharefileUri

    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
