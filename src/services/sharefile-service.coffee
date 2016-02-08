_            = require 'lodash'
NodeUUID         = require 'uuid'
StatusDevice = require 'friendly-sharefile/src/models/status-device'

class SharefileService
  constructor: ({@token,@sharefileDomain,@jobManager,@meshbluConfig}) ->

  getMetadata: ({itemId,path}, callback) =>
    jobType = 'getMetadataById' if itemId?
    jobType = 'getMetadataByPath' if path?
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  getItem: ({itemId,path}, callback) =>
    jobType = 'getItemById' if itemId?
    jobType = 'getItemByPath' if path?

    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  share: ({itemId,path,email,title}, callback) =>
    jobType = 'shareById' if itemId?
    jobType = 'shareByPath' if path?

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
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  getChildren: ({itemId,path}, callback) =>
    jobType = 'getChildrenById' if itemId?
    jobType = 'getChildrenByPath' if path?
    @_do jobType, {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  uploadFile: ({itemId,path,fileName,title,description}, contents, callback) =>
    jobType = 'uploadFileById' if itemId?
    jobType = 'uploadFileByPath' if path?
    @_do jobType, {itemId,path,fileName,title,description}, contents, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  downloadFile: ({itemId,path}, callback) =>
    jobType = 'downloadFileById' if itemId?
    jobType = 'downloadFileByPath' if path?
    @_do jobType, {itemId,path}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = response.metadata
      body = JSON.parse response.rawData
      callback null, @_createResponse code, body

  initiateTransfer: ({itemId,uuid,path,link,fileName}, callback) =>
    statusDevice = new StatusDevice {@meshbluConfig}
    statusDevice.create {link,uuid}, (error, device) =>
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
      @jobManager.createRequest 'request', message, (error) =>
        return callback @_createError 500, error.message if error?
        response =
          uploading: true
          background: true
          statusDevice:
            uuid: device.uuid
        callback null, @_createResponse 201, response

  _do: (jobType, options, data, callback) =>
    metadata = {}
    metadata.options = options
    metadata.token = @token
    metadata.domain = @sharefileDomain
    metadata.jobType = jobType
    @jobManager.do 'request', 'response', {metadata,data}, callback

  _createResponse: (code, body) =>
    return code: code, body: body

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = SharefileService
