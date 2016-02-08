_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
MeshbluConfig    = require 'meshblu-config'
JobManager       = require 'meshblu-core-job-manager'
RedisNS          = require '@octoblu/redis-ns'
redis            = require 'fakeredis'
uuid             = require 'uuid'
ShareFileService = require '../index.js'

class TransferCommand
  run: =>
    @redisKey = uuid.v1()
    @parseOptions()
    @initiateTransfer()
    client = new RedisNS 'friendly-sharefile-service', redis.createClient @redisKey
    jobManager = new JobManager client: client, timeoutSeconds: 45
    jobManager.getRequest ['request'], (error, result) =>
      return console.error error if error?
      return console.log 'timed out' unless result?
      @transferLinkFile result

  initiateTransfer: =>
    @initiateTransferByPath() if @path?
    @initiateTransferById() if @itemId?

  initiateTransferById: =>
    @_getSharefileService().initiateTransferById {@link, @itemId, @fileName}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  initiateTransferByPath: =>
    @_getSharefileService().initiateTransferByPath {@link, @path,@fileName}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  transferLinkFile: ({metadata}) =>
    {statusDevice,link,fileName,itemId} = metadata
    @transferLinkFileById({statusDevice,link,fileName,itemId})

  transferLinkFileById: ({statusDevice,link,fileName,itemId}) =>
    @_getSharefileService().transferLinkFileById {statusDevice,link,fileName,itemId}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  _getSharefileService: =>
    client = new RedisNS 'friendly-sharefile-service', redis.createClient @redisKey
    jobManager = new JobManager client: client, timeoutSeconds: 45
    meshbluConfig = new MeshbluConfig filename: @filename
    sharefileService = new ShareFileService {@token, @sharefileDomain,jobManager,meshbluConfig}

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The target folder itemId (must have either itemId or path)'
      .option '-p, --path <path>', 'The target folder path (must have either itemId or path)'
      .option '-l, --link <link>', 'Shared link to transfer to Sharefile'
      .option '-f, --fileName <fileName.txt>', 'File name with extension (optional)'
      .usage '[options] path/to/meshblu.json'
      .parse process.argv

    @filename = _.first commander.args
    @sharefileDomain = commander.Domain
    @token = commander.token
    @path = commander.path
    @itemId = commander.id
    @link = commander.link
    @fileName = commander.fileName

    unless @sharefileDomain? and @token? and @link?
      commander.outputHelp()
      process.exit 0

    unless @path? or @itemId?
      console.log 'Missing Path or Item ID'
      commander.outputHelp()
      process.exit 0

(new TransferCommand()).run()
