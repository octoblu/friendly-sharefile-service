_                = require 'lodash'
commander        = require 'commander'
colors           = require 'colors'
fs               = require 'fs'
path             = require 'path'
ShareFileService = require '../index.js'

class UploadCommand
  run: =>
    @parseOptions()
    @uploadFile()

  uploadFile: =>
    # return
    @uploadFileByPath() if @path?
    @uploadFileById() if @itemId?

  getFileData: =>
    fs.readFileSync path.resolve(@filename)

  uploadFileById: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    fileName = path.basename @filename
    sharefileService.uploadFileById {fileName, @title, @description, @batchId, @batchLast, @itemId}, @getFileData(), (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  uploadFileByPath: =>
    sharefileService = new ShareFileService {@token, @sharefileDomain}
    fileName = path.basename @filename
    console.log 'info', {fileName, @title, @description, @batchId, @batchLast, @path}
    console.log 'data', @getFileData()
    sharefileService.uploadFileByPath {fileName, @title, @description, @batchId, @batchLast, @path}, @getFileData(), (error, result) =>
      return console.log colors.red "Error: #{error.message}" if error?
      console.log JSON.stringify result.body, null, 2

  parseOptions: =>
    commander
      .option '-D, --Domain <Domain>', 'The domain name for Sharefile'
      .option '-t, --token <token>', 'The token for Sharefile'
      .option '-i, --id <itemId>', 'The target folder itemId (must have either itemId or path)'
      .option '-p, --path <path>', 'The target folder path (must have either itemId or path)'
      .option '-b, --batchId <batchId>', 'The upload batchId (optional)'
      .option '-l, --batchLast', 'If set this will be the end of the upload'
      .option '-t, --title <title>', 'The file title (optional)'
      .option '--desciption <desciption>', 'The file desciption (optional)'
      .usage '[options] path/to/file'
      .parse process.argv

    @filename = _.first commander.args
    @sharefileDomain = commander.Domain
    @token = commander.token
    @path = commander.path
    @itemId = commander.id
    @batchId = commander.batchId
    @batchLast = commander.batchLast?
    @title = commander.title
    @desciption = commander.desciption

    unless @sharefileDomain? and @token?
      commander.outputHelp()
      process.exit 0

    unless @path? or @itemId?
      commander.outputHelp()
      process.exit 0

(new UploadCommand()).run()
