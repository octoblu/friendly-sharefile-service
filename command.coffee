_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
JobManager    = require 'meshblu-core-job-manager'
redis         = require 'redis'
RedisNS       = require '@octoblu/redis-ns'
Server        = require './src/server'

class Command
  constructor: ->
    @serverOptions =
      port                 : process.env.PORT || 80
      disableLogging       : process.env.DISABLE_LOGGING == "true"

    @redisUri = process.env.REDIS_URI || 'redis://127.0.0.1:6379'

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    return @panic new Error 'Missing enviromnent REDIS_URI' unless @redisUri?

    meshbluConfig = new MeshbluConfig().toJSON()
    client = new RedisNS 'friendly-sharefile-service', redis.createClient @redisUri

    jobManager = new JobManager client: client, timeoutSeconds: 30
    server = new Server @serverOptions, {meshbluConfig,jobManager}
    
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
