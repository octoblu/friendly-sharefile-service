_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class MetadataCommand
  run: =>
    @parseOptions()
    @getMetadata()

  getMetadata: =>
    # return
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.metadata {@name,@itemId}, (error, result) =>
      return console.log colors.red "Error getting metadata: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The metadata itemId'
      .parse process.argv

    @sharefileDomain = commander.Domain
    @token = commander.token
    @itemId = commander.id

    unless @sharefileDomain? and @token? and @itemId?
      commander.outputHelp()
      process.exit 0

(new MetadataCommand()).run()
