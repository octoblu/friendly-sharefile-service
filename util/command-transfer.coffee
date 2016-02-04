_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class TransferCommand
  run: =>
    @parseOptions()
    @transferFile()

  transferFile: =>
    # return
    if @type == 'dropbox'
      @transferDropboxFileByPath() if @path?
      @transferDropboxFileById() if @itemId?

  transferDropboxFileById: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.transferDropboxFileById {@link, @itemId}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  transferDropboxFileByPath: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.transferDropboxFileByPath {@link, @path}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The target folder itemId (must have either itemId or path)'
      .option '-p, --path <path>', 'The target folder path (must have either itemId or path)'
      .option '-l, --link <link>', 'Shared link to transfer to Sharefile'
      .option '-T, --type <dropbox>', 'Service to transfer the file from. (dropbox)'
      .parse process.argv

    @filename = _.first commander.args
    @sharefileDomain = commander.Domain
    @token = commander.token
    @path = commander.path
    @itemId = commander.id
    @link = commander.link
    @type = commander.type

    unless @sharefileDomain? and @token? and @link?
      commander.outputHelp()
      process.exit 0

    unless @path? or @itemId?
      console.log 'Missing Path or Item ID'
      commander.outputHelp()
      process.exit 0

    unless @type in ['dropbox']
      console.log 'Invalid Type'
      commander.outputHelp()
      process.exit 0

(new TransferCommand()).run()
