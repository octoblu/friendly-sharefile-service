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
    @namespace = process.env.NAMESPACE || 'friendly-sharefile'
    @timeoutSeconds = parseInt process.env.TIMEOUT_SECONDS || 20

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    meshbluConfig = new MeshbluConfig().toJSON()
    client = new RedisNS @namespace, redis.createClient @redisUri

    jobManager = new JobManager client: client, timeoutSeconds: @timeoutSeconds
    server = new Server @serverOptions, {meshbluConfig,jobManager}

    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
