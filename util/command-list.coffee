_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
ShareFileService = require '../index.js'

class ListCommand
  run: =>
    @parseOptions()
    @getList()

  getList: =>
    # return
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    sharefileService.list {}, (error, result) =>
      return console.log colors.red "Error getting files: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .parse process.argv

    @sharefileDomain = commander.Domain
    @token = commander.token

    unless @sharefileDomain? and @token?
      commander.outputHelp()
      process.exit 0

(new ListCommand()).run()
