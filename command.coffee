MeshbluConfig  = require 'meshblu-config'
JobManager     = require 'meshblu-core-job-manager'
redis          = require 'redis'
SigtermHandler = require 'sigterm-handler'
RedisNS        = require '@octoblu/redis-ns'
Server         = require './src/server'

class Command
  constructor: ->
    @serverOptions =
      port            : process.env.PORT || 80
      disableLogging  : process.env.DISABLE_LOGGING == "true"

    @redisUri         = process.env.REDIS_URI || 'redis://127.0.0.1:6379'
    @namespace        = process.env.NAMESPACE || 'friendly-sharefile'
    @timeoutSeconds   = parseInt process.env.TIMEOUT_SECONDS || 120
    @jobLogQueue      = process.env.JOB_LOG_QUEUE
    @jobLogRedisUri   = process.env.JOB_LOG_REDIS_URI
    @jobLogSampleRate = parseFloat process.env.JOB_LOG_SAMPLE_RATE || '0.01'

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    meshbluConfig = new MeshbluConfig().toJSON()
    client = new RedisNS @namespace, redis.createClient @redisUri

    jobManagerOptions = { client, @timeoutSeconds, @jobLogRedisUri, @jobLogQueue, @jobLogSampleRate }
    jobManager = new JobManager jobManagerOptions
    server = new Server @serverOptions, {meshbluConfig,jobManager}

    server.run (error) =>
      return @panic error if error?

      {port} = server.address()
      console.log "Friendly Sharefile Service listening on port #{port}"

    sigtermHandler = new SigtermHandler { events: [ 'SIGTERM', 'SIGINT' ]}
    sigtermHandler.register server.stop

command = new Command()
command.run()
