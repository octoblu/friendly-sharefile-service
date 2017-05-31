_            = require 'lodash'
NodeUUID     = require 'uuid'
StatusDevice = require 'friendly-sharefile/src/models/status-device'
debug        = require('debug')('friendly-sharefile-service:sharefile-service')

class SharefileService
  constructor: ({@token,@sharefileDomain,@jobManager,@meshbluConfig}) ->

  getMetadata: ({itemId,path}, callback) =>
    jobType = 'getMetadataById' if itemId?
    jobType = 'getMetadataByPath' if path?
    return @_createError 422, 'Missing itemId or path' unless jobType?
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  getItem: ({itemId,path}, callback) =>
    jobType = 'getItemById' if itemId?
    jobType = 'getItemByPath' if path?
    return @_createError 422, 'Missing itemId or path' unless jobType?
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  share: ({itemId,path,email,title}, callback) =>
    jobType = 'shareById' if itemId?
    jobType = 'shareByPath' if path?
    return @_createError 422, 'Missing itemId or path' unless jobType?
    @_do jobType, {itemId,path,email,title}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  getHomeFolder: (callback) =>
    @_do 'getHomeFolder', {}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  getTreeView: ({itemId,path}, callback) =>
    jobType = 'getTreeViewById' if itemId?
    jobType = 'getTreeViewByPath' if path?
    return @_createError 422, 'Missing itemId or path' unless jobType?
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  getChildren: ({itemId,path}, callback) =>
    jobType = 'getChildrenById' if itemId?
    jobType = 'getChildrenByPath' if path?
    return @_createError 422, 'Missing itemId or path' unless jobType?
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  uploadFile: (options, contents, callback) =>
    debug 'uploadFile options:', JSON.stringify(options,null,2)
    debug 'uploadFile contents:', JSON.stringify(contents,null,2)
    {itemId,path,fileName,title,description} = options
    jobType = 'uploadFileById' if itemId?
    jobType = 'uploadFileByPath' if path?
    return @_createError 422, 'Missing itemId or path' unless jobType?
    return @_createError 422, 'Upload file requires contents in body' unless contents?
    @_do jobType, {itemId,path,fileName,title,description}, contents, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  downloadFile: ({itemId,path}, callback) =>
    jobType = 'downloadFileById' if itemId?
    jobType = 'downloadFileByPath' if path?
    return @_createError 422, 'Missing itemId or path' unless jobType?
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  initiateTransfer: ({itemId,uuid,path,link,fileName}, callback) =>
    return callback @_createError 422, 'Missing link' unless link
    return callback @_createError 422, 'Missing fileName' unless fileName
    return callback @_createError 422, 'Missing itemId or path' unless itemId || path

    statusDevice = new StatusDevice {@meshbluConfig}
    statusDevice.create {link,uuid,fileName}, (error, device) =>
      return callback @_createError 500, error.message if error?
      deviceConfig = _.cloneDeep @meshbluConfig
      deviceConfig.uuid = device.uuid
      deviceConfig.token = device.token
      jobType = 'transferLinkFileById' if itemId?
      jobType = 'transferLinkFileByPath' if path?
      message =
        metadata:
          responseId: NodeUUID.v4()
          options:
            statusDeviceConfig: deviceConfig
            link: link
            fileName: fileName
            itemId: itemId
            path: path
          token: @token
          domain: @sharefileDomain
          jobType: jobType
        data: {}
      @jobManager.createForeverRequest 'request', message, (error) =>
        return callback @_createError 500, error.message if error?
        response =
          uploading: true
          background: true
          statusDevice: deviceConfig
          monitor:
            description: 'Go to the link below to watch the status of your files being transfered'
            url: 'http://progress-monitor.octoblu.com'
        callback null, @_createResponse 201, response

  _do: (jobType, options, data, callback) =>
    metadata = {}
    metadata.options = options
    metadata.token = @token
    metadata.domain = @sharefileDomain
    metadata.jobType = jobType
    message = {metadata,data}
    debug '_do message:', JSON.stringify(message,null,2)
    @jobManager.do 'request', 'response', message, callback

  _createResponse: (code, body) =>
    return code: code, body: body

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = SharefileService
