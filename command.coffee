_             = require 'lodash'
Server        = require './src/server'

class Command
  constructor: ->
    @serverOptions =
      port                 : process.env.PORT || 80
      disableLogging       : process.env.DISABLE_LOGGING == "true"

    @sharefileUri = process.env.SHAREFILE_URI

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    @panic new Error('Missing required environment variable: SHAREFILE_URI') if _.isEmpty @sharefileUri

    server = new Server @serverOptions, {@sharefileUri}
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
