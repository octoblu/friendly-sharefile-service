_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class ShareCommand
  run: =>
    @parseOptions()
    @getShare()

  getShare: =>
    # return
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.share {@title,@email,@itemId}, (error, result) =>
      return console.log colors.red "Error getting share: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The share itemId'
      .option '-T, --title <title>', 'The share title'
      .option '-e, --email <email>', 'The share email'
      .parse process.argv

    @sharefileDomain = commander.Domain
    @token = commander.token
    @title = commander.title
    @email = commander.email
    @itemId = commander.id

    unless @sharefileDomain? and @token? and @itemId? and @email? and @title?
      commander.outputHelp()
      process.exit 0

(new ShareCommand()).run()
