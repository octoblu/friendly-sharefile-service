_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class FilesCommand
  run: =>
    @parseOptions()
    @getFiles()

  getFiles: =>
    # return
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.files {@itemId}, (error, result) =>
      return console.log colors.red "Error getting files: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The file itemId'
      .parse process.argv

    @sharefileDomain = commander.Domain
    @token = commander.token
    @itemId = commander.id

    unless @sharefileDomain? and @token? and @itemId?
      commander.outputHelp()
      process.exit 0

(new FilesCommand()).run()
