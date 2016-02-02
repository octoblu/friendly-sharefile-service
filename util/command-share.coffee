_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class ShareCommand
  run: =>
    @parseOptions()
    @share()

  share: =>
    # return
    @shareByPath() if @path?
    @shareById() if @itemId?

  shareById: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.shareById {@title,@email,@itemId}, (error, result) =>
      return console.log colors.red "Error getting share: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  shareByPath: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.shareByPath {@title,@email,@path}, (error, result) =>
      return console.log colors.red "Error getting share: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <id>', 'The share id (must use either path or id)'
      .option '-p, --path <path>', 'The share path (must use either path or id)'
      .option '-T, --title <title>', 'The share title'
      .option '-e, --email <email>', 'The share email'
      .parse process.argv

    @sharefileDomain = commander.Domain
    @token = commander.token
    @title = commander.title
    @email = commander.email
    @itemId = commander.id
    @path = commander.path

    unless @sharefileDomain? and @token? and @email? and @title?
      commander.outputHelp()
      process.exit 0

    unless @path? or @itemId?
      commander.outputHelp()
      process.exit 0

(new ShareCommand()).run()
