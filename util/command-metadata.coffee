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
    @getMetadataByPath() if @path?
    @getMetadataById() if @itemId?

  getMetadataById: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.getMetadataById {@itemId}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  getMetadataByPath: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.getMetadataByPath {@path}, (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The file itemId (must have either itemId or path)'
      .option '-p, --path <path>', 'The file path (must have either itemId or path)'
      .parse process.argv

    @sharefileDomain = commander.Domain
    @token = commander.token
    @itemId = commander.id
    @path = commander.path

    unless @sharefileDomain? and @token?
      commander.outputHelp()
      process.exit 0

    unless @path? or @itemId?
      commander.outputHelp()
      process.exit 0

(new MetadataCommand()).run()
