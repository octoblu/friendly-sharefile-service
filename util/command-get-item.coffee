_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class GetItemIdCommand
  run: =>
    @parseOptions()
    @getList()

  getList: =>
    # return
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.getItemByPath {@path}, (error, result) =>
      return console.log colors.red "Error getting files: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-p, --path <path>', 'The path item'
      .parse process.argv

    @sharefileDomain = commander.Domain
    @token = commander.token
    @path = commander.path

    unless @sharefileDomain? and @token? and @path?
      commander.outputHelp()
      process.exit 0

(new GetItemIdCommand()).run()
