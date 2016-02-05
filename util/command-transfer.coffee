_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class TransferCommand
  run: =>
    @parseOptions()
    @transferFile()

  transferFile: =>
    @transferLinkFileByPath() if @path?
    @transferLinkFileById() if @itemId?

  transferLinkFileById: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.transferLinkFileById {@link, @itemId, @fileName}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  transferLinkFileByPath: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.transferLinkFileByPath {@link, @path,@fileName}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The target folder itemId (must have either itemId or path)'
      .option '-p, --path <path>', 'The target folder path (must have either itemId or path)'
      .option '-l, --link <link>', 'Shared link to transfer to Sharefile'
      .option '-f, --fileName <fileName.txt>', 'File name with extension (optional)'
      .parse process.argv

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
